import tempfile
from PIL import Image
import fitz
import google.generativeai as genai
import re
import json
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv

from langchain_core.messages import HumanMessage, AIMessage

load_dotenv()
google_api_key = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=google_api_key)

# ------------------------------
# Pydantic model
# ------------------------------
class ReportDetails(BaseModel):
    patient_report_for: Optional[str] = None   # Who report belongs to / diagnosis type
    disease_name: Optional[str] = None
    disease_list_match: Optional[bool] = None
    doctor_name: Optional[str] = None
    hospital_address: Optional[str] = None
    end: bool = False

# ------------------------------
# Gemini config
# ------------------------------
generation_config = {
    "temperature": 0.7,
    "top_p": 1,
    "top_k": 0,
    "max_output_tokens": 4096,
}

safety_settings = [
    {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
]

model = genai.GenerativeModel(
    "gemini-1.5-flash",
    generation_config=generation_config,
    safety_settings=safety_settings
)

# ------------------------------
# Extract text from image
# ------------------------------
def extract_text_from_image(image: Image.Image) -> str:
    try:
        with tempfile.NamedTemporaryFile(suffix=".jpeg", delete=True) as tmp_file:
            image.save(tmp_file.name, format="JPEG")
            uploaded_file = genai.upload_file(path=tmp_file.name)

            # Prompt instructing AI to analyze patient report & detect disease
            prompt = """
            Analyze this medical report page. Extract the following:
            1. Patient / report type (who this report belongs to)
            2. Disease name (match with provided disease list if possible)
            3. Prescribing doctor
            4. Hospital address

            Respond ONLY in JSON like:
            {
              "patient_report_for": "...",
              "disease_name": "...",
              "doctor_name": "...",
              "hospital_address": "..."
            }

            If info is missing, set null.
            """

            response = model.generate_content([prompt, uploaded_file])
            if hasattr(response, "text"):
                clean_text = re.sub(r"```(?:json)?", "", response.text).strip("` \n")
                match = re.search(r"(\{.*\})", clean_text, re.DOTALL)
                if match:
                    return match.group(1)
    except Exception as e:
        print(f"Error: {e}")
    return "{}"

# ------------------------------
# Parse PDF with AI inference + memory
# ------------------------------
def parse_pdf_auto(pdf_path: str, disease_list: List[str], memory: List = None) -> ReportDetails:
    memory = memory or []
    details = ReportDetails(end=False)

    doc = fitz.open(pdf_path)
    for i, page in enumerate(doc, start=1):
        pix = page.get_pixmap()
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        json_text = extract_text_from_image(img)
        try:
            data = json.loads(json_text)
        except:
            data = {}

        # Patient/report owner
        if data.get("patient_report_for"):
            details.patient_report_for = data["patient_report_for"]
            memory.append(AIMessage(content=f"Report belongs to: {details.patient_report_for}"))

        # Disease
        disease_name = data.get("disease_name")
        if disease_name:
            matched_name = disease_name if disease_name in disease_list else disease_name
            details.disease_name = matched_name
            details.disease_list_match = disease_name in disease_list
            memory.append(AIMessage(content=f"Detected disease: {matched_name}"))

        # Doctor
        if data.get("doctor_name"):
            details.doctor_name = data["doctor_name"]
            memory.append(AIMessage(content=f"Doctor: {details.doctor_name}"))

        # Hospital
        if data.get("hospital_address"):
            details.hospital_address = data["hospital_address"]
            memory.append(AIMessage(content=f"Hospital: {details.hospital_address}"))

        # Stop early if all info found
        if details.patient_report_for and details.disease_name and details.doctor_name and details.hospital_address:
            details.end = True
            break

    details.end = True
    return details, memory

# ------------------------------
# Example usage
# ------------------------------
if __name__ == "__main__":
    pdf_file = "test1.PDF"
    diseases = ["Glycogen Storage Disease", "Diabetes", "Hypertension"]
    conversation_memory = []

    final_details, updated_memory = parse_pdf_auto(pdf_file, diseases, conversation_memory)

    print(final_details.dict())
    print("Conversation memory:")
    for msg in updated_memory:
        print(f"{msg.__class__.__name__}: {msg.content}")

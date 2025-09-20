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

# ------------------------------
# Load API key
# ------------------------------
load_dotenv()
google_api_key = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=google_api_key)

# ------------------------------
# Pydantic model
# ------------------------------
class ReportDetails(BaseModel):
    disease_name: Optional[str] = None
    disease_list_match: Optional[bool] = None
    doctor_name: Optional[str] = None
    hospital_address: Optional[str] = None
    end: bool = False
    questions: Optional[List[str]] = None

# ------------------------------
# Gemini config
# ------------------------------
model = genai.GenerativeModel("gemini-1.5-flash")

# ------------------------------
# Extract text from image
# ------------------------------
def extract_text_from_image(image: Image.Image) -> dict:
    try:
        with tempfile.NamedTemporaryFile(suffix=".jpeg", delete=True) as tmp_file:
            image.save(tmp_file.name, format="JPEG")
            uploaded_file = genai.upload_file(path=tmp_file.name)

            prompt = """
            Analyze this medical report page. Extract the following:
            1. Disease name (AI should detect it)
            2. Prescribing doctor
            3. Hospital address

            Respond ONLY in JSON like:
            {
              "disease_name": "...",
              "doctor_name": "...",
              "hospital_address": "..."
            }

            If info is missing or uncertain, put null.
            """

            response = model.generate_content([prompt, uploaded_file])
            if hasattr(response, "text"):
                clean_text = re.sub(r"```(?:json)?", "", response.text).strip("` \n")
                match = re.search(r"(\{.*\})", clean_text, re.DOTALL)
                if match:
                    return json.loads(match.group(1))
    except Exception as e:
        print(f"Error: {e}")
    return {}

# ------------------------------
# Ask LLM to generate questions for missing info
# ------------------------------
def generate_questions(missing_fields: List[str]) -> List[str]:
    if not missing_fields:
        return []

    prompt = f"""
    The following fields are missing in the medical report: {missing_fields}.
    Ask the user polite and clear questions to get this info.
    Example:
    - "Could you please tell me the doctor's name?"
    - "What is the hospital address?"
    """

    response = model.generate_content(prompt)
    if hasattr(response, "text"):
        return [q.strip("- ").strip() for q in response.text.split("\n") if q.strip()]
    return []

# ------------------------------
# Parse PDF
# ------------------------------
def parse_pdf_auto(pdf_path: str, disease_list: List[str], memory: List = None) -> ReportDetails:
    memory = memory or []
    details = ReportDetails(end=False, questions=[])

    doc = fitz.open(pdf_path)
    extracted = {}

    for page in doc:
        pix = page.get_pixmap()
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        page_data = extract_text_from_image(img)
        extracted.update({k: v for k, v in page_data.items() if v})

    # ------------------------------
    # Disease check with list
    # ------------------------------
    if extracted.get("disease_name"):
        matched = None
        for d in disease_list:
            if d.lower() in extracted["disease_name"].lower():
                matched = d
                break
        details.disease_name = matched if matched else extracted["disease_name"]
        details.disease_list_match = bool(matched)

    # Doctor & hospital
    details.doctor_name = extracted.get("doctor_name")
    details.hospital_address = extracted.get("hospital_address")

    # ------------------------------
    # Find missing fields
    # ------------------------------
    missing = []
    if not details.disease_name:
        missing.append("disease_name")
    if not details.doctor_name:
        missing.append("doctor_name")
    if not details.hospital_address:
        missing.append("hospital_address")

    details.questions = generate_questions(missing)
    details.end = len(missing) == 0

    # Add to memory
    memory.append(AIMessage(content=f"Extracted details: {details.dict()}"))
    if details.questions:
        for q in details.questions:
            memory.append(AIMessage(content=q))

    return details, memory

# ------------------------------
# Update with user response
# ------------------------------
def update_with_user_response(details: ReportDetails, memory: List, user_input: str):
    """
    User ka reply lega aur AI ko bhej kar decide karega ki konsa field fill ho raha hai.
    """
    prompt = f"""
    Current details: {details.dict()}
    User said: "{user_input}"

    Decide which field (disease_name, doctor_name, hospital_address) this user input belongs to.
    Return JSON only like:
    {{
      "field": "...",
      "value": "..."
    }}
    If it doesn't match, put field as null.
    """

    response = model.generate_content(prompt)
    field, value = None, None
    if hasattr(response, "text"):
        try:
            data = json.loads(response.text)
            field, value = data.get("field"), data.get("value")
        except:
            pass

    if field and value:
        setattr(details, field, value)
        memory.append(HumanMessage(content=f"User provided {field}: {value}"))

    # Re-check missing
    missing = []
    if not details.disease_name:
        missing.append("disease_name")
    if not details.doctor_name:
        missing.append("doctor_name")
    if not details.hospital_address:
        missing.append("hospital_address")

    details.questions = generate_questions(missing)
    details.end = len(missing) == 0

    if details.questions:
        for q in details.questions:
            memory.append(AIMessage(content=q))

    return details, memory

# ------------------------------
# Example usage
# ------------------------------
if __name__ == "__main__":
    pdf_file = "test.pdf"
    diseases = ["Glycogen Storage Disease", "Diabetes", "Hypertension"]

    details, memory = parse_pdf_auto(pdf_file, diseases, [])

    print("AI First Parse:", details.dict())
    print("\nChat so far:")
    for msg in memory:
        print(f"{msg.__class__.__name__}: {msg.content}")
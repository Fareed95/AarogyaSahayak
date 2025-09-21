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
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage

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
    doctor_name: Optional[str] = None
    hospital_address: Optional[str] = None
    end: bool = False
    questions: Optional[List[str]] = None

class PageReport(BaseModel):
    page_number: int
    details: ReportDetails

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

system_prompt = """
You are a medical report parser. Your task is to extract the following details from a medical report image:

- disease_name
- doctor_name
- hospital_address
- end (True if report ends, else False)
- questions (list any questions if needed)

Please respond ONLY in pure JSON using this format:

{
    "disease_name": "Example Disease",
    "doctor_name": "Dr. ABC",
    "hospital_address": "XYZ Hospital",
    "end": false,
    "questions": ["Question 1", "Question 2"]
}

Do NOT explain anything. Do NOT include code blocks. Respond with valid JSON only.
"""

# ------------------------------
# Models
# ------------------------------
report_model = genai.GenerativeModel(
    "gemini-1.5-flash",
    generation_config=generation_config,
    safety_settings=safety_settings
)

summary_model = ChatOpenAI(temperature=0.7)

# ------------------------------
# Extract from a single image
# ------------------------------
def extract_report_details_from_image(image: Image.Image) -> Optional[ReportDetails]:
    try:
        with tempfile.NamedTemporaryFile(suffix=".jpeg", delete=True) as tmp_file:
            image.save(tmp_file.name, format="JPEG")
            uploaded_file = genai.upload_file(path=tmp_file.name)
            response = report_model.generate_content([system_prompt, uploaded_file])

            if hasattr(response, "text"):
                clean_text = re.sub(r"```(?:json)?", "", response.text).strip("` \n")
                match = re.search(r"(\{.*\})", clean_text, re.DOTALL)
                if match:
                    data = json.loads(match.group(1))
                    return ReportDetails(**data)
    except Exception as e:
        print(f"Error: {e}")
    return None

# ------------------------------
# Extract from PDF
# ------------------------------
def extract_report_from_pdf(pdf_path: str) -> List[PageReport]:
    results = []
    doc = fitz.open(pdf_path)
    for i, page in enumerate(doc, start=1):
        pix = page.get_pixmap()
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        details = extract_report_details_from_image(img)
        if details:
            results.append(PageReport(page_number=i, details=details))
    return results

# ------------------------------
# Generate overall summary
# ------------------------------
def generate_report_summary(page_reports: List[PageReport]) -> str:
    data_for_summary = [r.dict() for r in page_reports]

    prompt = f"""
    You are a medical report summarizer.
    Here are the extracted details from all pages:

    {json.dumps(data_for_summary, indent=2)}

    Generate a human-readable summary of the report,
    mentioning diseases, doctors, hospital info, end status,
    and any follow-up questions. Keep it professional.
    """
    response = summary_model([HumanMessage(content=prompt)])
    return response.content.strip()

# ------------------------------
# Main
# ------------------------------
if __name__ == "__main__":
    pdf_file = "test.pdf"
    final_results = extract_report_from_pdf(pdf_file)

    # Convert Pydantic models to dicts for JSON output
    output_json = [r.dict() for r in final_results]

    # Print structured JSON
    print(json.dumps(output_json, indent=2))

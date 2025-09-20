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

load_dotenv()
google_api_key = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=google_api_key)

# Pydantic models
class TestResult(BaseModel):
    Name: str
    Found: float
    Range: Optional[str] = None

class PageResults(BaseModel):
    page_number: int
    tests: List[TestResult]

# Gemini config
generation_config = {
    "temperature": 0.9,
    "top_p": 1,
    "top_k": 0,
    "max_output_tokens": 8192,
}

safety_settings = [
    {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
    {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
]

system_prompt = """
You are a medical report parser. Your task is to extract test values from a medical image.

Please respond ONLY in pure JSON format using this structure:

[
  {
    "Name": "Glycogen",
    "Found": 120,
    "Range": "90-110"
  }
]

Do NOT explain anything.
Do NOT include code blocks or formatting.
Respond with valid, parsable JSON only.
"""

model = genai.GenerativeModel(
    "gemini-1.5-flash",
    generation_config=generation_config,
    safety_settings=safety_settings
)

# Function to extract from a single image
def extract_medical_json_from_image(image: Image.Image):
    try:
        with tempfile.NamedTemporaryFile(suffix=".jpeg", delete=True) as tmp_file:
            image.save(tmp_file.name, format="JPEG")
            uploaded_file = genai.upload_file(path=tmp_file.name)
            response = model.generate_content([system_prompt, uploaded_file])

            if hasattr(response, "text"):
                clean_text = re.sub(r"```(?:json)?", "", response.text).strip("` \n")
                match = re.search(r"(\{.*\}|\[.*\])", clean_text, re.DOTALL)
                if match:
                    data = json.loads(match.group(1))
                    return [TestResult(**item) for item in data]
    except Exception as e:
        print(f"Error: {e}")
    return None

# Function to handle PDF
def extract_medical_from_pdf(pdf_path: str) -> List[PageResults]:
    results = []
    doc = fitz.open(pdf_path)
    for i, page in enumerate(doc, start=1):
        pix = page.get_pixmap()
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        tests = extract_medical_json_from_image(img)
        if tests:
            results.append(PageResults(page_number=i, tests=tests))
    return results

# Example usage
if __name__ == "__main__":
    pdf_file = "test1.PDF"
    final_results = extract_medical_from_pdf(pdf_file)
    print([r.dict() for r in final_results])

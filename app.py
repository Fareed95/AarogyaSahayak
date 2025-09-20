import os
import tempfile
from typing import List, Dict, Optional
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from groq import Groq
from fastapi.middleware.cors import CORSMiddleware
import pytesseract
from PIL import Image
import io
import speech_recognition as sr
from gtts import gTTS
import base64

# Load environment variables
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_API_KEY:
    raise ValueError("API key for Groq is missing. Please set GROQ_API_KEY in .env")

app = FastAPI()

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

client = Groq(api_key=GROQ_API_KEY)

# ---------------- Models ----------------
class AudioRequest(BaseModel):
    conversation_id: str = "default"
    prompt: Optional[str] = None

# ---------------- Helpers ----------------
def extract_text_from_image(image_data: bytes) -> str:
    """Extract text from image using OCR"""
    try:
        image = Image.open(io.BytesIO(image_data))
        text = pytesseract.image_to_string(image)
        return text.strip()
    except Exception as e:
        raise Exception(f"OCR processing failed: {str(e)}")

def process_audio_file(audio_data: bytes, filename: str) -> str:
    """Process audio file and convert to text"""
    recognizer = sr.Recognizer()
    file_extension = os.path.splitext(filename)[1] if filename else ".webm"

    with tempfile.NamedTemporaryFile(suffix=file_extension, delete=False) as temp_file:
        temp_file.write(audio_data)
        temp_file.flush()

        try:
            # Try Groq Whisper first
            with open(temp_file.name, "rb") as audio_file:
                transcription = client.audio.transcriptions.create(
                    file=audio_file,
                    model="whisper-large-v3",
                    response_format="text",
                )
                return transcription.strip()
        except Exception as e:
            print(f"Groq Whisper failed, trying speech_recognition: {e}")
            try:
                # Fallback to speech_recognition
                with sr.AudioFile(temp_file.name) as source:
                    recognizer.adjust_for_ambient_noise(source, duration=0.5)
                    audio = recognizer.record(source)
                    return recognizer.recognize_google(audio)
            except Exception as e2:
                print(f"Fallback speech recognition failed: {e2}")
                raise Exception("Could not process audio")
        finally:
            try:
                os.unlink(temp_file.name)
            except:
                pass

def text_to_speech(text: str) -> str:
    """Convert text to speech and return base64 encoded audio"""
    try:
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as temp_file:
            tts = gTTS(text=text, lang="en")
            tts.save(temp_file.name)
            
            # Read the file and encode as base64
            with open(temp_file.name, "rb") as audio_file:
                audio_data = audio_file.read()
                return base64.b64encode(audio_data).decode('utf-8')
    except Exception as e:
        raise Exception(f"Text-to-speech conversion failed: {str(e)}")
    finally:
        try:
            os.unlink(temp_file.name)
        except:
            pass

def query_groq_api(messages: List[Dict[str, str]]) -> str:
    try:
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=messages,
            temperature=0.7,
            max_tokens=1024,
            top_p=1,
            stream=False,
        )
        return completion.choices[0].message.content
    except Exception as e:
        raise Exception(f"Error with Groq API: {str(e)}")

# ---------------- Endpoints ----------------
@app.post("/process_image_ocr/")
async def process_image_ocr(
    conversation_id: str = Form("default"),
    prompt: str = Form(None),
    image: UploadFile = File(...)
):
    """Process image, extract text with OCR, combine with prompt, and get AI response"""
    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_data = await image.read()
    
    try:
        extracted_text = extract_text_from_image(image_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    if not extracted_text:
        raise HTTPException(status_code=400, detail="No text could be extracted from the image")
    
    user_content = extracted_text
    if prompt:
        user_content = f"{prompt}\n\nHere is the text from the image:\n{extracted_text}"
    
    messages = [
        {
            "role": "system",
            "content": (
                "You are an intelligent AI assistant. Respond naturally to the user's input. "
                "If they provide text from an image, respond appropriately to that content."
            ),
        },
        {
            "role": "user",
            "content": user_content
        }
    ]
    
    # Get AI response
    try:
        ai_response = query_groq_api(messages)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    return JSONResponse({
        "extracted_text": extracted_text,
        "ai_response": ai_response,
        "conversation_id": conversation_id,
        "user_prompt": prompt
    })

@app.post("/process_audio/")
async def process_audio(
    conversation_id: str = Form("default"),
    prompt: str = Form(None),
    audio: UploadFile = File(...)
):
    """Process audio, convert to text, combine with prompt, and get AI response"""
    if not audio.content_type.startswith("audio/"):
        raise HTTPException(status_code=400, detail="File must be an audio file")

    # Read and process audio
    audio_data = await audio.read()
    
    # Convert audio to text
    try:
        transcribed_text = process_audio_file(audio_data, audio.filename or "audio.webm")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    if not transcribed_text:
        raise HTTPException(status_code=400, detail="No speech could be recognized from the audio")
    
    user_content = transcribed_text
    if prompt:
        user_content = f"{prompt}\n\nHere is the transcribed audio:\n{transcribed_text}"
    messages = [
        {
            "role": "system",
            "content": (
                "You are an intelligent AI assistant. Respond naturally to the user's input. "
                "If they provide transcribed audio, respond appropriately to that content."
            ),
        },
        {
            "role": "user",
            "content": user_content
        }
    ]
    
    # Get AI response
    try:
        ai_response = query_groq_api(messages)
        
        # Convert AI response to speech
        audio_base64 = text_to_speech(ai_response)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    return JSONResponse({
        "transcribed_text": transcribed_text,
        "ai_response": ai_response,
        "audio_base64": audio_base64,
        "conversation_id": conversation_id,
        "user_prompt": prompt
    })

@app.post("/voice_chat/")
async def voice_chat(
    conversation_id: str = Form(...), 
    audio: UploadFile = File(...)
):
    """Process audio and return only AI response without showing transcribed text"""
    if not audio.content_type.startswith("audio/"):
        raise HTTPException(status_code=400, detail="File must be an audio file")
    audio_data = await audio.read()
    try:
        transcribed_text = process_audio_file(audio_data, audio.filename or "audio.webm")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    if not transcribed_text:
        raise HTTPException(status_code=400, detail="No speech could be recognized from the audio")
    
    # Prepare messages for Groq API
    messages = [
        {
            "role": "system",
            "content": (
                "You are an intelligent AI assistant designed to assist you."
               
            ),
        },
        {
            "role": "user",
            "content": transcribed_text
        }
    ]
    
    try:
        ai_response = query_groq_api(messages)
        
        # Convert AI response to speech
        audio_response_file = text_to_speech(ai_response)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    return JSONResponse({
        "ai_response": ai_response,
        "audio_url": f"/download_audio/{os.path.basename(audio_response_file)}",
        "conversation_id": conversation_id,
    })

@app.post("/text_chat/")
async def text_chat(
    conversation_id: str = Form("default"),
    message: str = Form(...)
):
    """Process text message and get AI response"""
    if not message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    
    messages = [
        {
            "role": "system",
            "content": "You are an intelligent AI assistant. Respond naturally to the user's input.",
        },
        {
            "role": "user",
            "content": message
        }
    ]
    
    # Get AI response
    try:
        ai_response = query_groq_api(messages)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    return JSONResponse({
        "user_message": message,
        "ai_response": ai_response,
        "conversation_id": conversation_id
    })

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
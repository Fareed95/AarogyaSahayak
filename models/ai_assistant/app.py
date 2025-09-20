import os
import tempfile
import uuid
import asyncio
from typing import List, Dict, Optional
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, WebSocket, WebSocketDisconnect
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
from datetime import datetime, timedelta
import json

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
class StartCallRequest(BaseModel):
    user_id: str

class EndCallRequest(BaseModel):
    session_id: str

class VoiceChatRequest(BaseModel):
    user_id: str
    audio_data: str
    session_id: str

# Store active sessions and connections
active_sessions = {}
active_connections = {}

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
    file_extension = os.path.splitext(filename)[1] if filename else ".wav"

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
            tts = gTTS(text=text, lang="en", slow=False)
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

# ---------------- Voice Call Endpoints ----------------
@app.post("/start-call")
async def start_call(request: StartCallRequest):
    """Start a new voice call session"""
    try:
        session_id = str(uuid.uuid4())
        
        # Create greeting message
        greeting = "Hello! I'm Dr. Sarah, your voice medical assistant. How can I help you today?"
        
        # Generate audio greeting
        audio_greeting = text_to_speech(greeting)
        
        # Store session
        active_sessions[session_id] = {
            "user_id": request.user_id,
            "start_time": datetime.now(),
            "last_activity": datetime.now(),
            "conversation_history": [
                {"role": "system", "content": "You are Dr. Sarah, a friendly medical assistant."},
                {"role": "assistant", "content": greeting}
            ]
        }
        
        return {
            "success": True,
            "session_id": session_id,
            "greeting": greeting,
            "audio_greeting": audio_greeting
        }
        
    except Exception as e:
        return {
            "success": False,
            "message": f"Failed to start call: {str(e)}"
        }

@app.post("/end-call")
async def end_call(request: EndCallRequest):
    """End a voice call session"""
    try:
        if request.session_id in active_sessions:
            del active_sessions[request.session_id]
        
        # Close WebSocket connection if exists
        if request.session_id in active_connections:
            await active_connections[request.session_id].close()
            del active_connections[request.session_id]
        
        return {"success": True, "message": "Call ended successfully"}
        
    except Exception as e:
        return {
            "success": False,
            "message": f"Failed to end call: {str(e)}"
        }

@app.post("/voice-chat")
async def voice_chat_endpoint(request: VoiceChatRequest):
    """Process voice chat with audio data"""
    try:
        # Check if session exists
        if request.session_id not in active_sessions:
            return {
                "success": False,
                "response_text": "Session not found. Please start a new call.",
                "audio_response": ""
            }
        
        # Update last activity
        active_sessions[request.session_id]["last_activity"] = datetime.now()
        
        # Decode base64 audio
        audio_bytes = base64.b64decode(request.audio_data)
        
        # Process audio to text
        transcribed_text = process_audio_file(audio_bytes, "voice_message.wav")
        
        if not transcribed_text:
            return {
                "success": False,
                "response_text": "I couldn't understand that. Please try speaking again.",
                "audio_response": ""
            }
        
        # Add user message to conversation history
        active_sessions[request.session_id]["conversation_history"].append({
            "role": "user",
            "content": transcribed_text
        })
        
        # Get AI response using full conversation history
        try:
            ai_response = query_groq_api(active_sessions[request.session_id]["conversation_history"])
            
            # Add AI response to conversation history
            active_sessions[request.session_id]["conversation_history"].append({
                "role": "assistant",
                "content": ai_response
            })
            
            # Convert AI response to speech
            audio_response = text_to_speech(ai_response)
            
        except Exception as e:
            raise Exception(f"AI response failed: {str(e)}")
        
        return {
            "success": True,
            "response_text": ai_response,
            "audio_response": audio_response
        }
        
    except Exception as e:
        return {
            "success": False,
            "response_text": f"Sorry, I encountered an error: {str(e)}",
            "audio_response": ""
        }

# ---------------- WebSocket for Real-time Voice Call ----------------
@app.websocket("/ws/voice-call/{session_id}")
async def websocket_voice_call(websocket: WebSocket, session_id: str):
    await websocket.accept()
    
    # Verify session exists
    if session_id not in active_sessions:
        await websocket.send_json({
            "type": "error",
            "message": "Invalid session ID"
        })
        await websocket.close()
        return
    
    # Store connection
    active_connections[session_id] = websocket
    
    try:
        # Send welcome message
        await websocket.send_json({
            "type": "status",
            "message": "Connected to Dr. Sarah"
        })
        
        while True:
            # Receive audio data from client
            data = await websocket.receive_json()
            
            if data.get("type") == "audio":
                # Process audio data
                audio_data = data.get("audio_data", "")
                
                if audio_data:
                    # Decode base64 audio
                    audio_bytes = base64.b64decode(audio_data)
                    
                    # Process audio to text
                    transcribed_text = process_audio_file(audio_bytes, "voice_message.wav")
                    
                    if transcribed_text:
                        print(f"User said: {transcribed_text}")
                        
                        # Add to conversation history
                        active_sessions[session_id]["conversation_history"].append({
                            "role": "user",
                            "content": transcribed_text
                        })
                        
                        # Get AI response
                        ai_response = query_groq_api(active_sessions[session_id]["conversation_history"])
                        
                        # Add AI response to history
                        active_sessions[session_id]["conversation_history"].append({
                            "role": "assistant",
                            "content": ai_response
                        })
                        
                        # Convert to audio
                        audio_response = text_to_speech(ai_response)
                        
                        # Send response back to client
                        await websocket.send_json({
                            "type": "response",
                            "text": ai_response,
                            "audio": audio_response
                        })
                    else:
                        await websocket.send_json({
                            "type": "response",
                            "text": "I didn't catch that. Could you please repeat?",
                            "audio": ""
                        })
            
            elif data.get("type") == "end_call":
                # End the call
                if session_id in active_sessions:
                    del active_sessions[session_id]
                await websocket.send_json({
                    "type": "call_ended",
                    "message": "Call ended successfully"
                })
                break
                
    except WebSocketDisconnect:
        print(f"Client disconnected from session {session_id}")
    except Exception as e:
        print(f"WebSocket error: {e}")
        await websocket.send_json({
            "type": "error",
            "message": f"Connection error: {str(e)}"
        })
    finally:
        # Clean up
        if session_id in active_connections:
            del active_connections[session_id]
        if session_id in active_sessions:
            del active_sessions[session_id]

# ---------------- Existing Endpoints (Keep these) ----------------
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

# Clean up old sessions periodically
@app.on_event("startup")
async def startup_event():
    async def cleanup_sessions():
        while True:
            await asyncio.sleep(300)  # Clean up every 5 minutes
            now = datetime.now()
            sessions_to_remove = []
            for session_id, session_data in active_sessions.items():
                if now - session_data["last_activity"] > timedelta(minutes=30):
                    sessions_to_remove.append(session_id)
            
            for session_id in sessions_to_remove:
                if session_id in active_sessions:
                    del active_sessions[session_id]
                if session_id in active_connections:
                    await active_connections[session_id].close()
                    del active_connections[session_id]
    
    asyncio.create_task(cleanup_sessions())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
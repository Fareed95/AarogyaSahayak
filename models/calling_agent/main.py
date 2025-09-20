from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import os
from dotenv import load_dotenv
import json
import asyncio
from typing import Dict, Optional
import uuid
from datetime import datetime
import io
import wave
import base64

# Load environment variables
load_dotenv()

app = FastAPI(title="Voice Health AI Calling Agent")

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set OpenAI API key
openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key:
    raise ValueError("OPENAI_API_KEY not found in environment variables")

openai.api_key = openai_api_key

# Store active calls
active_calls: Dict[str, Dict] = {}

class ChatRequest(BaseModel):
    user_id: str
    text: str

class VoiceCallRequest(BaseModel):
    user_id: str
    audio_data: str  # Base64 encoded audio
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    response_text: str
    success: bool = True
    audio_response: Optional[str] = None  # Base64 encoded audio response

class CallSession(BaseModel):
    session_id: str
    user_id: str
    conversation_history: list
    created_at: datetime
    status: str  # "active", "ended"

@app.get("/")
async def health_check():
    return {"status": "healthy", "service": "Voice Health AI Agent"}

@app.post("/start-call", response_model=dict)
async def start_call(user_id: str):
    """Initialize a new voice call session"""
    session_id = str(uuid.uuid4())
    
    call_session = {
        "session_id": session_id,
        "user_id": user_id,
        "conversation_history": [
            {"role": "system", "content": """You are Dr. Sarah, a professional and empathetic medical assistant. 
            You provide accurate medical information while maintaining a warm, conversational tone suitable for voice interaction.
            
            Guidelines:
            - Always recommend consulting healthcare professionals for serious concerns
            - Keep responses concise and clear for voice interaction (2-3 sentences max)
            - Be empathetic and supportive
            - Ask relevant follow-up questions when appropriate
            - Use natural, conversational language
            - If you need clarification, ask specific questions
            - For emergencies, immediately recommend calling emergency services
            
            Start the conversation by greeting the caller warmly and asking how you can help them today."""}
        ],
        "created_at": datetime.now(),
        "status": "active"
    }
    
    active_calls[session_id] = call_session
    
    # Generate initial greeting
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=call_session["conversation_history"],
            max_tokens=100,
            temperature=0.7
        )
        
        greeting = response.choices[0].message.content
        call_session["conversation_history"].append({"role": "assistant", "content": greeting})
        
        # Convert text to speech (you'll need to implement TTS)
        audio_response = await text_to_speech(greeting)
        
        return {
            "session_id": session_id,
            "greeting": greeting,
            "audio_greeting": audio_response,
            "success": True
        }
        
    except Exception as e:
        return {"error": str(e), "success": False}

@app.post("/voice-chat", response_model=ChatResponse)
async def voice_chat(request: VoiceCallRequest):
    """Process voice input and return voice response"""
    try:
        # Get or create session
        if request.session_id not in active_calls:
            return ChatResponse(
                response_text="Session not found. Please start a new call.",
                success=False
            )
        
        session = active_calls[request.session_id]
        
        # Convert audio to text using OpenAI Whisper
        user_text = await speech_to_text(request.audio_data)
        
        if not user_text:
            return ChatResponse(
                response_text="I didn't catch that. Could you please repeat?",
                success=True
            )
        
        # Add user message to conversation history
        session["conversation_history"].append({"role": "user", "content": user_text})
        
        # Generate AI response
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=session["conversation_history"],
            max_tokens=150,
            temperature=0.7
        )
        
        ai_response = response.choices[0].message.content
        session["conversation_history"].append({"role": "assistant", "content": ai_response})
        
        # Convert response to speech
        audio_response = await text_to_speech(ai_response)
        
        return ChatResponse(
            response_text=ai_response,
            audio_response=audio_response,
            success=True
        )
        
    except Exception as e:
        return ChatResponse(
            response_text=f"Sorry, I encountered an error: {str(e)}",
            success=False
        )

@app.post("/end-call")
async def end_call(session_id: str):
    """End a voice call session"""
    if session_id in active_calls:
        active_calls[session_id]["status"] = "ended"
        # Here you could save the conversation to a database
        return {"message": "Call ended successfully", "success": True}
    return {"message": "Session not found", "success": False}

@app.get("/call-history/{user_id}")
async def get_call_history(user_id: str):
    """Get call history for a user"""
    user_calls = [call for call in active_calls.values() if call["user_id"] == user_id]
    return {"calls": user_calls}

# WebSocket endpoint for real-time voice communication
@app.websocket("/ws/voice-call/{session_id}")
async def voice_call_websocket(websocket: WebSocket, session_id: str):
    await websocket.accept()
    
    try:
        if session_id not in active_calls:
            await websocket.send_json({"error": "Session not found"})
            await websocket.close()
            return
        
        session = active_calls[session_id]
        
        while True:
            # Receive audio data from client
            data = await websocket.receive_text()
            message = json.loads(data)
            
            if message["type"] == "audio":
                # Process audio input
                user_text = await speech_to_text(message["audio_data"])
                
                if user_text:
                    # Add to conversation history
                    session["conversation_history"].append({"role": "user", "content": user_text})
                    
                    # Generate AI response
                    response = openai.ChatCompletion.create(
                        model="gpt-3.5-turbo",
                        messages=session["conversation_history"],
                        max_tokens=150,
                        temperature=0.7
                    )
                    
                    ai_response = response.choices[0].message.content
                    session["conversation_history"].append({"role": "assistant", "content": ai_response})
                    
                    # Convert to speech and send back
                    audio_response = await text_to_speech(ai_response)
                    
                    await websocket.send_json({
                        "type": "response",
                        "text": ai_response,
                        "audio": audio_response
                    })
            
            elif message["type"] == "end_call":
                session["status"] = "ended"
                await websocket.send_json({"type": "call_ended"})
                break
                
    except WebSocketDisconnect:
        if session_id in active_calls:
            active_calls[session_id]["status"] = "ended"
    except Exception as e:
        await websocket.send_json({"error": str(e)})

async def speech_to_text(audio_data: str) -> str:
    """Convert speech to text using OpenAI Whisper API"""
    try:
        # Decode base64 audio data
        audio_bytes = base64.b64decode(audio_data)
        
        # Create a temporary audio file
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = "audio.wav"
        
        # Use OpenAI Whisper API
        transcript = openai.Audio.transcribe(
            model="whisper-1",
            file=audio_file,
            language="en"
        )
        
        return transcript.text
        
    except Exception as e:
        print(f"Speech to text error: {e}")
        return ""

async def text_to_speech(text: str) -> str:
    """Convert text to speech - you'll need to implement this with a TTS service"""
    try:
        # Option 1: Use OpenAI's TTS API (if available)
        # Option 2: Use Google Cloud Text-to-Speech
        # Option 3: Use Amazon Polly
        # Option 4: Use Azure Cognitive Services
        
        # For now, returning empty string - implement based on your preferred TTS service
        # Example with OpenAI TTS:
        """
        response = openai.Audio.speech.create(
            model="tts-1",
            voice="alloy",
            input=text,
        )
        
        # Convert to base64
        audio_base64 = base64.b64encode(response.content).decode()
        return audio_base64
        """
        
        # Placeholder - implement with your chosen TTS service
        return ""
        
    except Exception as e:
        print(f"Text to speech error: {e}")
        return ""

# Text-based chat endpoint (keeping your original functionality)
@app.post("/call-agent", response_model=ChatResponse)
async def call_agent(request: ChatRequest):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a professional health assistant. Provide accurate medical information, but always recommend consulting with healthcare professionals for serious concerns. Be empathetic and helpful."},
                {"role": "user", "content": request.text}
            ],
            max_tokens=150
        )
        
        agent_response = response.choices[0].message.content
        return ChatResponse(response_text=agent_response, success=True)
        
    except Exception as e:
        return ChatResponse(response_text=f"Sorry, I encountered an error: {str(e)}", success=False)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
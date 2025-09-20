from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(title="Health AI Calling Agent")

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

class ChatRequest(BaseModel):
    user_id: str
    text: str

class ChatResponse(BaseModel):
    response_text: str
    success: bool = True

@app.get("/")
async def health_check():
    return {"status": "healthy", "service": "Health AI Agent"}

@app.post("/call-agent", response_model=ChatResponse)
async def call_agent(request: ChatRequest):
    try:
        # Create a conversation with the health AI agent
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
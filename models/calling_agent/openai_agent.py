import os
import openai
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
openai.api_key = OPENAI_API_KEY

def call_agent(user_text: str, user_id: str):
    """
    Simulate the OpenMic agent using OpenAI GPT model
    """
    prompt = f"""
You are Aarogya Sahayak, a friendly healthcare assistant for chronic disease management.
You are talking to user {user_id}.
Respond in a simple, friendly, and actionable way.
User says: "{user_text}"
"""
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=300
    )
    reply = response.choices[0].message.content
    return {"response": reply}

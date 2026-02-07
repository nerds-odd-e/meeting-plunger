from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI

from config import OPENAI_API_KEY

app = FastAPI(title="Meeting Plunger API")

# Initialize OpenAI client
openai_client = OpenAI(api_key=OPENAI_API_KEY)

# Configure CORS for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Meeting Plunger API", "status": "running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):  # noqa: B008
    """Transcribe audio file using OpenAI API."""
    # Read the uploaded file content
    audio_content = await file.read()
    
    # Create a temporary file-like object for OpenAI API
    audio_file = (file.filename, audio_content, file.content_type)
    
    # Call OpenAI Transcription API
    transcript = openai_client.audio.transcriptions.create(
        model="gpt-4o-mini-transcribe",
        file=audio_file
    )
    
    return {"transcript": transcript.text}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)

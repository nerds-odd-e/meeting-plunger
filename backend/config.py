import os

from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# OpenAI Configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Note: OPENAI_API_KEY validation is deferred to runtime when actually needed.
# This allows importing the module (e.g., for OpenAPI schema generation) without requiring the key.

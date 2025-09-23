"""
Environment configuration for FastAPI backend
"""

import os
import logging
from dotenv import load_dotenv

# Setup logger
logger = logging.getLogger(__name__)

# Load environment variables
try:
    load_dotenv()
except Exception as e:
    logger.warning(f"Could not load .env file: {e}")
    logger.info("Continuing with system environment variables only")

class Config:
    """Application configuration"""
    
    # FastAPI Configuration
    FASTAPI_BASE_URL = os.getenv("FASTAPI_BASE_URL", "http://localhost:8000")
    FASTAPI_API_KEY = os.getenv("FASTAPI_API_KEY", "your-secret-api-key")
    
    # Supabase Configuration
    SUPABASE_URL = os.getenv("SUPABASE_URL")
    SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
    SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
    
    # Database Configuration
    DATABASE_URL = os.getenv("DATABASE_URL")
    
    # Server Configuration
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8000))
    RELOAD = os.getenv("RELOAD", "true").lower() == "true"
    
    # Security Configuration
    SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = 30
    
    # CORS Configuration
    ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
    
    # Logging Configuration
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    
    # AI Configuration (for future AI features)
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
    
    @classmethod
    def validate_config(cls):
        """Validate required configuration"""
        required_vars = [
            "SUPABASE_URL",
            "SUPABASE_ANON_KEY",
            "FASTAPI_API_KEY"
        ]
        
        missing_vars = []
        for var in required_vars:
            if not getattr(cls, var):
                missing_vars.append(var)
        
        if missing_vars:
            raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")
        
        return True

# Validate configuration on import (only in production)
if os.getenv("APP_ENV", "development") == "production":
    try:
        Config.validate_config()
    except ValueError as e:
        logger.error(f"Configuration validation failed: {e}")
        raise

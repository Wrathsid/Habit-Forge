"""
FastAPI Backend for Habit Tracker App
Main application entry point with API key authentication
"""

from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv
import uvicorn

from routers import (
    habits,
    analytics,
    social,
    notifications,
    health,
    auth,
    test
)
from middleware.auth_middleware import verify_api_key
from database.supabase_client import SupabaseClient
from utils.logger import setup_logger

# Load environment variables
load_dotenv()

# Setup logger
logger = setup_logger(__name__)

# Security scheme
security = HTTPBearer()

# Global Supabase client
supabase_client = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    global supabase_client
    
    # Startup
    logger.info("Starting Habit Tracker API...")
    
    try:
        # Initialize Supabase client
        supabase_client = SupabaseClient()
        await supabase_client.initialize()
        app.state.supabase = supabase_client
        logger.info("Supabase client initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Supabase client: {str(e)}")
        logger.warning("API will continue without database connection")
        supabase_client = None
        app.state.supabase = None
    
    logger.info("API startup complete")
    
    yield
    
    # Shutdown
    logger.info("Shutting down Habit Tracker API...")
    try:
        if supabase_client:
            await supabase_client.close()
            logger.info("Supabase client closed successfully")
    except Exception as e:
        logger.error(f"Error closing Supabase client: {str(e)}")
    
    logger.info("API shutdown complete")

# Create FastAPI app
app = FastAPI(
    title="Habit Tracker API",
    description="AI-powered habit tracking API with social features",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(
    auth.router,
    prefix="/auth",
    tags=["Authentication"],
    dependencies=[Depends(verify_api_key)]
)

app.include_router(
    habits.router,
    prefix="/habits",
    tags=["Habits"],
    dependencies=[Depends(verify_api_key)]
)

app.include_router(
    analytics.router,
    prefix="/analytics",
    tags=["Analytics"],
    dependencies=[Depends(verify_api_key)]
)

app.include_router(
    social.router,
    prefix="/social",
    tags=["Social"],
    dependencies=[Depends(verify_api_key)]
)

app.include_router(
    notifications.router,
    prefix="/notifications",
    tags=["Notifications"],
    dependencies=[Depends(verify_api_key)]
)

app.include_router(
    test.router,
    prefix="/test",
    tags=["Test"]
)

app.include_router(
    health.router,
    prefix="/health",
    tags=["Health"]
)

@app.get("/")
async def root():
    """Root endpoint"""
    try:
        return {
            "message": "Habit Tracker API",
            "version": "1.0.0",
            "status": "running",
            "timestamp": "2024-01-01T00:00:00Z"
        }
    except Exception as e:
        logger.error(f"Error in root endpoint: {str(e)}")
        return {
            "message": "Habit Tracker API",
            "version": "1.0.0",
            "status": "error",
            "error": str(e)
        }

@app.get("/docs")
async def get_docs():
    """API documentation endpoint"""
    try:
        return {
            "docs_url": "/docs", 
            "redoc_url": "/redoc",
            "openapi_url": "/openapi.json"
        }
    except Exception as e:
        logger.error(f"Error in docs endpoint: {str(e)}")
        return {
            "error": "Failed to get documentation",
            "docs_url": "/docs", 
            "redoc_url": "/redoc"
        }

if __name__ == "__main__":
    try:
        # Get configuration from environment
        host = os.getenv("HOST", "0.0.0.0")
        port_str = os.getenv("PORT", "8000")
        reload = os.getenv("RELOAD", "true").lower() == "true"
        
        # Validate port
        try:
            port = int(port_str)
            if port < 1 or port > 65535:
                raise ValueError("Port must be between 1 and 65535")
        except ValueError as e:
            logger.error(f"Invalid port configuration: {e}")
            port = 8000  # Default fallback
        
        logger.info(f"Starting server on {host}:{port}")
        
        uvicorn.run(
            "main:app",
            host=host,
            port=port,
            reload=reload,
            log_level="info"
        )
    except Exception as e:
        logger.error(f"Failed to start server: {str(e)}")
        raise

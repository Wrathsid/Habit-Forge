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
    
    # Initialize Supabase client
    supabase_client = SupabaseClient()
    await supabase_client.initialize()
    app.state.supabase = supabase_client
    
    logger.info("API startup complete")
    
    yield
    
    # Shutdown
    logger.info("Shutting down Habit Tracker API...")
    if supabase_client:
        await supabase_client.close()
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
    return {
        "message": "Habit Tracker API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/docs")
async def get_docs():
    """API documentation endpoint"""
    return {"docs_url": "/docs", "redoc_url": "/redoc"}

if __name__ == "__main__":
    # Get configuration from environment
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    reload = os.getenv("RELOAD", "true").lower() == "true"
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=reload,
        log_level="info"
    )

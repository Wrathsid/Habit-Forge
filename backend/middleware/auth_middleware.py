"""
Authentication middleware for API key verification
"""

from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from config import Config
import logging

logger = logging.getLogger(__name__)

security = HTTPBearer()

async def verify_api_key(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Verify API key from Authorization header
    
    Expected format: Bearer <api_key>
    """
    try:
        api_key = credentials.credentials
        
        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="API key is required",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        if api_key != Config.FASTAPI_API_KEY:
            logger.warning(f"Invalid API key attempt: {api_key[:10]}...")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid API key",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        logger.debug("API key verified successfully")
        return {"api_key": api_key}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error verifying API key: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during authentication"
        )

async def verify_api_key_optional(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Optional API key verification for public endpoints
    """
    try:
        api_key = credentials.credentials
        
        if api_key and api_key == Config.FASTAPI_API_KEY:
            return {"api_key": api_key, "authenticated": True}
        else:
            return {"api_key": None, "authenticated": False}
            
    except Exception:
        return {"api_key": None, "authenticated": False}

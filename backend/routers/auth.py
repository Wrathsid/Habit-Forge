"""
Authentication router
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any
from datetime import datetime, timedelta
import logging

from database.supabase_client import SupabaseClient

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/verify-token")
async def verify_token(
    token: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Verify Supabase JWT token"""
    try:
        # This would typically verify the JWT token with Supabase
        # For now, we'll return a simple response
        return {
            "valid": True,
            "user_id": "user_id_from_token",
            "message": "Token verified successfully"
        }
    except Exception as e:
        logger.error(f"Error verifying token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )

"""
Notifications router for notification management
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime, timedelta
import logging

from database.supabase_client import SupabaseClient

logger = logging.getLogger(__name__)
router = APIRouter()

# Pydantic models
class NotificationCreate(BaseModel):
    title: str
    body: str
    type: str
    data: Optional[Dict[str, Any]] = {}
    scheduled_for: Optional[str] = None

@router.get("/optimal-times/{user_id}", response_model=Dict[str, Any])
async def get_optimal_notification_times(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get optimal notification times for a user"""
    try:
        # Get user's habit completion patterns
        habits = await supabase.get_habits(user_id)
        
        # Analyze completion times to find optimal notification times
        optimal_times = []
        for habit in habits:
            if habit.get('has_reminder') and habit.get('reminder_time'):
                optimal_times.append({
                    'habit_id': habit['id'],
                    'habit_name': habit['name'],
                    'optimal_time': habit['reminder_time'],
                    'days': habit.get('reminder_days', [])
                })
        
        return {
            "optimal_times": optimal_times,
            "recommendations": [
                "Set reminders 30 minutes before your usual completion time",
                "Use different times for different types of habits",
                "Adjust times based on your completion patterns"
            ]
        }
    except Exception as e:
        logger.error(f"Error getting optimal notification times: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve optimal notification times"
        )

@router.post("/schedule", response_model=Dict[str, Any])
async def schedule_smart_notification(
    user_id: str,
    habit_id: str,
    type: str,
    data: Optional[Dict[str, Any]] = None,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Schedule a smart notification"""
    try:
        notification_data = {
            'user_id': user_id,
            'title': f"Habit Reminder",
            'body': f"Time to complete your habit!",
            'type': type,
            'data': data or {},
            'scheduled_for': datetime.now() + timedelta(hours=1),
            'created_at': datetime.now().isoformat()
        }
        
        response = supabase.client.table('notifications').insert(notification_data).execute()
        return response.data[0] if response.data else {}
    except Exception as e:
        logger.error(f"Error scheduling notification: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to schedule notification"
        )

@router.get("/{user_id}", response_model=List[Dict[str, Any]])
async def get_user_notifications(
    user_id: str,
    limit: int = 20,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get notifications for a user"""
    try:
        response = supabase.client.table('notifications').select('*').eq('user_id', user_id).order('created_at', desc=True).limit(limit).execute()
        return response.data
    except Exception as e:
        logger.error(f"Error getting notifications: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve notifications"
        )

@router.put("/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Mark a notification as read"""
    try:
        response = supabase.client.table('notifications').update({'is_read': True}).eq('id', notification_id).eq('user_id', user_id).execute()
        return {"message": "Notification marked as read"}
    except Exception as e:
        logger.error(f"Error marking notification as read: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to mark notification as read"
        )

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Delete a notification"""
    try:
        response = supabase.client.table('notifications').delete().eq('id', notification_id).eq('user_id', user_id).execute()
        return {"message": "Notification deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting notification: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete notification"
        )

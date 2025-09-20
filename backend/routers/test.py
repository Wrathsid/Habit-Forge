"""
Test router for frontend-backend connection
"""

from fastapi import APIRouter
from datetime import datetime
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.get("/test")
async def test_connection():
    """Test endpoint to verify frontend-backend connection"""
    return {
        "message": "Frontend-Backend connection successful!",
        "timestamp": datetime.now().isoformat(),
        "status": "connected"
    }

@router.get("/analytics/habit-insights/{user_id}")
async def get_habit_insights(user_id: str):
    """Mock habit insights endpoint"""
    return {
        "user_id": user_id,
        "insights": [
            {
                "type": "completion_rate",
                "title": "Completion Rate Analysis",
                "description": "Your completion rate is excellent! Keep up the great work!",
                "data": {
                    "completion_rate": 85.5,
                    "total_completions": 42,
                    "total_habits": 5
                },
                "priority": 1
            },
            {
                "type": "streak_analysis", 
                "title": "Streak Performance",
                "description": "Amazing streak consistency! You are building strong habits.",
                "data": {
                    "average_streak": 7.2,
                    "recommendation": "Focus on one habit at a time for better consistency"
                },
                "priority": 2
            }
        ],
        "timestamp": datetime.now().isoformat()
    }

@router.get("/analytics/mood-analysis/{user_id}")
async def get_mood_analysis(user_id: str):
    """Mock mood analysis endpoint"""
    return {
        "user_id": user_id,
        "mood_trends": {
            "average_mood": 4.2,
            "trend": "improving",
            "correlation_with_habits": 0.75
        },
        "recommendations": [
            "Continue your morning meditation habit - it's boosting your mood!",
            "Consider adding more physical activity habits"
        ],
        "timestamp": datetime.now().isoformat()
    }

@router.get("/notifications/optimal-times/{user_id}")
async def get_optimal_notification_times(user_id: str):
    """Mock optimal notification times endpoint"""
    return {
        "user_id": user_id,
        "optimal_times": {
            "morning": "08:00",
            "afternoon": "14:00", 
            "evening": "19:00"
        },
        "timezone": "UTC",
        "timestamp": datetime.now().isoformat()
    }

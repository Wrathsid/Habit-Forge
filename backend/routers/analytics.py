"""
Analytics router for habit analytics and insights
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
import logging

from database.supabase_client import SupabaseClient

logger = logging.getLogger(__name__)
router = APIRouter()

@router.get("/habit-insights/{user_id}", response_model=Dict[str, Any])
async def get_habit_insights(
    user_id: str,
    days: int = 30,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get habit insights and analytics for a user"""
    if not user_id or not user_id.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User ID is required"
        )
    
    if days < 1 or days > 365:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Days must be between 1 and 365"
        )
    
    try:
        analytics_data = await supabase.get_habit_analytics(user_id)
        
        # Calculate additional insights
        insights = {
            "total_habits": len(analytics_data.get('habits', [])),
            "active_habits": len([h for h in analytics_data.get('habits', []) if h.get('is_active', True)]),
            "total_completions": sum(len(h.get('habit_completions', [])) for h in analytics_data.get('habits', [])),
            "average_streak": sum(s.get('current_streak', 0) for s in analytics_data.get('streaks', [])) / max(len(analytics_data.get('streaks', [])), 1),
            "longest_streak": max((s.get('best_streak', 0) for s in analytics_data.get('streaks', [])), default=0),
            "user_progress": analytics_data.get('progress', {}),
            "habits": analytics_data.get('habits', []),
            "streaks": analytics_data.get('streaks', [])
        }
        
        return insights
    except Exception as e:
        logger.error(f"Error getting habit insights: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habit insights"
        )

@router.get("/mood-analysis/{user_id}", response_model=Dict[str, Any])
async def get_mood_analysis(
    user_id: str,
    days: int = 30,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get mood analysis for a user"""
    if not user_id or not user_id.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User ID is required"
        )
    
    if days < 1 or days > 365:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Days must be between 1 and 365"
        )
    
    try:
        mood_checkins = await supabase.get_mood_checkins(user_id)
        
        if not mood_checkins:
            return {
                "average_mood": 0,
                "mood_trend": "No data",
                "total_entries": 0,
                "mood_distribution": {},
                "insights": []
            }
        
        # Calculate mood statistics
        mood_values = [m.get('mood_rating', 0) for m in mood_checkins]
        average_mood = sum(mood_values) / len(mood_values) if mood_values else 0
        
        # Mood distribution
        mood_distribution = {}
        for mood in mood_values:
            mood_distribution[mood] = mood_distribution.get(mood, 0) + 1
        
        # Mood trend (last 7 days)
        recent_moods = mood_values[:7] if len(mood_values) >= 7 else mood_values
        mood_trend = "stable"
        if len(recent_moods) >= 2:
            if recent_moods[0] > recent_moods[-1] + 0.5:
                mood_trend = "improving"
            elif recent_moods[0] < recent_moods[-1] - 0.5:
                mood_trend = "declining"
        
        return {
            "average_mood": round(average_mood, 2),
            "mood_trend": mood_trend,
            "total_entries": len(mood_checkins),
            "mood_distribution": mood_distribution,
            "recent_moods": recent_moods,
            "insights": [
                f"Average mood over {days} days: {round(average_mood, 2)}/5",
                f"Mood trend: {mood_trend}",
                f"Total mood entries: {len(mood_checkins)}"
            ]
        }
    except Exception as e:
        logger.error(f"Error getting mood analysis: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve mood analysis"
        )

@router.get("/habit-correlations/{user_id}", response_model=Dict[str, Any])
async def get_habit_correlations(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get habit correlations and patterns"""
    if not user_id or not user_id.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User ID is required"
        )
    
    try:
        analytics_data = await supabase.get_habit_analytics(user_id)
        
        # Simple correlation analysis
        habits = analytics_data.get('habits', [])
        correlations = []
        
        for i, habit1 in enumerate(habits):
            for j, habit2 in enumerate(habits[i+1:], i+1):
                # Calculate correlation based on completion patterns
                completions1 = len(habit1.get('habit_completions', []))
                completions2 = len(habit2.get('habit_completions', []))
                
                if completions1 > 0 and completions2 > 0:
                    correlation_strength = min(completions1, completions2) / max(completions1, completions2)
                    if correlation_strength > 0.7:
                        correlations.append({
                            "habit1": habit1['name'],
                            "habit2": habit2['name'],
                            "correlation": round(correlation_strength, 2),
                            "type": "positive"
                        })
        
        return {
            "correlations": correlations,
            "total_habits": len(habits),
            "insights": [
                f"Found {len(correlations)} strong habit correlations",
                "Habits with high correlation tend to be completed together"
            ]
        }
    except Exception as e:
        logger.error(f"Error getting habit correlations: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habit correlations"
        )

@router.get("/streak-prediction/{user_id}/{habit_id}", response_model=Dict[str, Any])
async def predict_streak_success(
    user_id: str,
    habit_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Predict streak success probability"""
    try:
        completions = await supabase.get_habit_completions(habit_id, user_id)
        
        if not completions:
            return {
                "prediction": "low",
                "probability": 0.3,
                "reason": "No completion history",
                "recommendations": ["Start with small goals", "Set reminders"]
            }
        
        # Simple prediction based on recent completion rate
        recent_completions = completions[:7]  # Last 7 days
        completion_rate = len(recent_completions) / 7
        
        if completion_rate >= 0.8:
            prediction = "high"
            probability = 0.9
        elif completion_rate >= 0.5:
            prediction = "medium"
            probability = 0.6
        else:
            prediction = "low"
            probability = 0.3
        
        recommendations = []
        if prediction == "low":
            recommendations = ["Reduce goal size", "Set daily reminders", "Find accountability partner"]
        elif prediction == "medium":
            recommendations = ["Maintain current routine", "Track progress daily"]
        else:
            recommendations = ["Great job!", "Consider increasing challenge", "Help others with similar goals"]
        
        return {
            "prediction": prediction,
            "probability": probability,
            "completion_rate": round(completion_rate, 2),
            "reason": f"Based on {len(recent_completions)}/7 recent completions",
            "recommendations": recommendations
        }
    except Exception as e:
        logger.error(f"Error predicting streak success: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to predict streak success"
        )

@router.get("/advanced/{user_id}", response_model=Dict[str, Any])
async def get_advanced_analytics(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get advanced analytics combining all data"""
    try:
        # Get all analytics data
        habit_insights = await get_habit_insights(user_id, supabase=supabase)
        mood_analysis = await get_mood_analysis(user_id, supabase=supabase)
        habit_correlations = await get_habit_correlations(user_id, supabase=supabase)
        
        # Combine insights
        advanced_analytics = {
            "habit_insights": habit_insights,
            "mood_analysis": mood_analysis,
            "habit_correlations": habit_correlations,
            "overall_score": 0,
            "recommendations": [],
            "generated_at": datetime.now().isoformat()
        }
        
        # Calculate overall score
        habit_score = min(habit_insights.get('total_completions', 0) / 100, 1.0)
        mood_score = mood_analysis.get('average_mood', 0) / 5
        overall_score = (habit_score + mood_score) / 2
        
        advanced_analytics["overall_score"] = round(overall_score, 2)
        
        # Generate recommendations
        recommendations = []
        if overall_score < 0.3:
            recommendations.append("Focus on building one consistent habit")
        elif overall_score < 0.6:
            recommendations.append("Great progress! Consider adding more habits")
        else:
            recommendations.append("Excellent! You're on track for your goals")
        
        advanced_analytics["recommendations"] = recommendations
        
        return advanced_analytics
    except Exception as e:
        logger.error(f"Error getting advanced analytics: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve advanced analytics"
        )

"""
Habits router for habit management endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime, date
import logging

from database.supabase_client import SupabaseClient

logger = logging.getLogger(__name__)
router = APIRouter()

# Pydantic models
class HabitCreate(BaseModel):
    name: str
    description: Optional[str] = None
    icon: str
    category_id: Optional[str] = None
    goal: int = 1
    goal_unit: str = "times"
    frequency: str = "daily"
    custom_days: Optional[List[int]] = None
    priority: int = 1
    xp_reward: int = 10
    reminder_time: Optional[str] = None
    reminder_days: Optional[List[int]] = None
    has_reminder: bool = False

class HabitUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    category_id: Optional[str] = None
    goal: Optional[int] = None
    goal_unit: Optional[str] = None
    frequency: Optional[str] = None
    custom_days: Optional[List[int]] = None
    priority: Optional[int] = None
    xp_reward: Optional[int] = None
    reminder_time: Optional[str] = None
    reminder_days: Optional[List[int]] = None
    has_reminder: Optional[bool] = None
    is_active: Optional[bool] = None

class HabitCompletion(BaseModel):
    habit_id: str
    completion_date: str
    completion_value: int = 1
    notes: Optional[str] = None
    mood_rating: Optional[int] = None

@router.get("/", response_model=List[Dict[str, Any]])
async def get_habits(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get all habits for a user"""
    try:
        habits = await supabase.get_habits(user_id)
        return habits
    except Exception as e:
        logger.error(f"Error getting habits: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habits"
        )

@router.post("/", response_model=Dict[str, Any])
async def create_habit(
    habit: HabitCreate,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Create a new habit"""
    try:
        habit_data = habit.dict()
        habit_data['user_id'] = user_id
        habit_data['created_at'] = datetime.now().isoformat()
        
        new_habit = await supabase.create_habit(habit_data)
        return new_habit
    except Exception as e:
        logger.error(f"Error creating habit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create habit"
        )

@router.get("/{habit_id}", response_model=Dict[str, Any])
async def get_habit(
    habit_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get a specific habit"""
    try:
        habits = await supabase.get_habits(user_id)
        habit = next((h for h in habits if h['id'] == habit_id), None)
        
        if not habit:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Habit not found"
            )
        
        return habit
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting habit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habit"
        )

@router.put("/{habit_id}", response_model=Dict[str, Any])
async def update_habit(
    habit_id: str,
    habit_update: HabitUpdate,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Update a habit"""
    try:
        updates = habit_update.dict(exclude_unset=True)
        updates['updated_at'] = datetime.now().isoformat()
        
        updated_habit = await supabase.update_habit(habit_id, updates)
        return updated_habit
    except Exception as e:
        logger.error(f"Error updating habit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update habit"
        )

@router.delete("/{habit_id}")
async def delete_habit(
    habit_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Delete a habit"""
    try:
        await supabase.delete_habit(habit_id)
        return {"message": "Habit deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting habit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete habit"
        )

@router.post("/complete", response_model=Dict[str, Any])
async def mark_habit_complete(
    completion: HabitCompletion,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Mark a habit as complete"""
    try:
        completion_data = completion.dict()
        completion_data['user_id'] = user_id
        
        result = await supabase.mark_habit_complete(
            completion.habit_id,
            user_id,
            completion.completion_date
        )
        return result
    except Exception as e:
        logger.error(f"Error marking habit complete: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to mark habit as complete"
        )

@router.get("/{habit_id}/completions", response_model=List[Dict[str, Any]])
async def get_habit_completions(
    habit_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get completions for a specific habit"""
    try:
        completions = await supabase.get_habit_completions(habit_id, user_id)
        return completions
    except Exception as e:
        logger.error(f"Error getting habit completions: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habit completions"
        )

@router.get("/templates/", response_model=List[Dict[str, Any]])
async def get_habit_templates(
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get available habit templates"""
    try:
        response = supabase.client.table('habit_templates').select('*').eq('is_active', True).execute()
        return response.data
    except Exception as e:
        logger.error(f"Error getting habit templates: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve habit templates"
        )

"""
Supabase client for database operations
"""

from supabase import create_client, Client
from config import Config
import logging
from typing import Optional, Dict, Any, List

logger = logging.getLogger(__name__)

class SupabaseClient:
    """Supabase client wrapper"""
    
    def __init__(self):
        self.client: Optional[Client] = None
        self.url = Config.SUPABASE_URL
        self.key = Config.SUPABASE_SERVICE_ROLE_KEY or Config.SUPABASE_ANON_KEY
    
    async def initialize(self):
        """Initialize Supabase client"""
        try:
            if not self.url or not self.key or self.url == "your-supabase-url-here":
                logger.warning("Supabase not configured - running in local mode")
                self.client = None
                return
            
            self.client = create_client(self.url, self.key)
            logger.info("Supabase client initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize Supabase client: {str(e)}")
            logger.warning("Continuing in local mode without Supabase")
            self.client = None
    
    async def close(self):
        """Close Supabase client"""
        self.client = None
        logger.info("Supabase client closed")
    
    # Habit operations
    async def get_habits(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all habits for a user"""
        if not self.client:
            logger.warning("Supabase client not initialized - returning empty list")
            return []
        try:
            response = self.client.table('habits').select('*').eq('user_id', user_id).execute()
            return response.data
        except Exception as e:
            logger.error(f"Error getting habits: {str(e)}")
            raise
    
    async def create_habit(self, habit_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new habit"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot create habit")
            raise Exception("Database not available")
        try:
            response = self.client.table('habits').insert(habit_data).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error creating habit: {str(e)}")
            raise
    
    async def update_habit(self, habit_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update a habit"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot update habit")
            raise Exception("Database not available")
        try:
            response = self.client.table('habits').update(updates).eq('id', habit_id).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error updating habit: {str(e)}")
            raise
    
    async def delete_habit(self, habit_id: str) -> bool:
        """Delete a habit"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot delete habit")
            raise Exception("Database not available")
        try:
            response = self.client.table('habits').delete().eq('id', habit_id).execute()
            return True
        except Exception as e:
            logger.error(f"Error deleting habit: {str(e)}")
            raise
    
    # Habit completion operations
    async def mark_habit_complete(self, habit_id: str, user_id: str, completion_date: str) -> Dict[str, Any]:
        """Mark a habit as complete for a specific date"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot mark habit complete")
            raise Exception("Database not available")
        try:
            completion_data = {
                'habit_id': habit_id,
                'user_id': user_id,
                'completion_date': completion_date,
                'completion_value': 1
            }
            response = self.client.table('habit_completions').upsert(completion_data).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error marking habit complete: {str(e)}")
            raise
    
    async def get_habit_completions(self, habit_id: str, user_id: str) -> List[Dict[str, Any]]:
        """Get habit completions for a specific habit"""
        if not self.client:
            logger.warning("Supabase client not initialized - returning empty list")
            return []
        try:
            response = self.client.table('habit_completions').select('*').eq('habit_id', habit_id).eq('user_id', user_id).execute()
            return response.data
        except Exception as e:
            logger.error(f"Error getting habit completions: {str(e)}")
            raise
    
    # User progress operations
    async def get_user_progress(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user progress"""
        if not self.client:
            logger.warning("Supabase client not initialized - returning None")
            return None
        try:
            response = self.client.table('user_progress').select('*').eq('user_id', user_id).execute()
            return response.data[0] if response.data else None
        except Exception as e:
            logger.error(f"Error getting user progress: {str(e)}")
            raise
    
    async def update_user_progress(self, user_id: str, progress_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update user progress"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot update user progress")
            raise Exception("Database not available")
        try:
            progress_data['user_id'] = user_id
            response = self.client.table('user_progress').upsert(progress_data).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error updating user progress: {str(e)}")
            raise
    
    # Mood tracking operations
    async def save_mood_checkin(self, mood_data: Dict[str, Any]) -> Dict[str, Any]:
        """Save mood check-in"""
        if not self.client:
            logger.warning("Supabase client not initialized - cannot save mood checkin")
            raise Exception("Database not available")
        try:
            response = self.client.table('mood_checkins').upsert(mood_data).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error saving mood checkin: {str(e)}")
            raise
    
    async def get_mood_checkins(self, user_id: str) -> List[Dict[str, Any]]:
        """Get mood check-ins for a user"""
        if not self.client:
            logger.warning("Supabase client not initialized - returning empty list")
            return []
        try:
            response = self.client.table('mood_checkins').select('*').eq('user_id', user_id).order('checkin_date', desc=True).execute()
            return response.data
        except Exception as e:
            logger.error(f"Error getting mood checkins: {str(e)}")
            raise
    
    # Analytics operations
    async def get_habit_analytics(self, user_id: str) -> Dict[str, Any]:
        """Get habit analytics for a user"""
        if not self.client:
            logger.warning("Supabase client not initialized - returning empty analytics")
            return {'habits': [], 'streaks': [], 'progress': {}}
        try:
            # Get habits with completions
            habits_response = self.client.table('habits').select('*, habit_completions(*)').eq('user_id', user_id).execute()
            
            # Get streaks
            streaks_response = self.client.table('streaks').select('*').eq('user_id', user_id).execute()
            
            # Get user progress
            progress_response = self.client.table('user_progress').select('*').eq('user_id', user_id).execute()
            
            return {
                'habits': habits_response.data,
                'streaks': streaks_response.data,
                'progress': progress_response.data[0] if progress_response.data else {}
            }
        except Exception as e:
            logger.error(f"Error getting habit analytics: {str(e)}")
            raise
    
    # Social operations
    async def get_friends(self, user_id: str) -> List[Dict[str, Any]]:
        """Get friends for a user"""
        try:
            response = self.client.table('friends').select('*, profiles(*)').eq('user_id', user_id).eq('status', 'accepted').execute()
            return response.data
        except Exception as e:
            logger.error(f"Error getting friends: {str(e)}")
            raise
    
    async def create_social_post(self, post_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a social post"""
        try:
            response = self.client.table('social_posts').insert(post_data).execute()
            return response.data[0] if response.data else {}
        except Exception as e:
            logger.error(f"Error creating social post: {str(e)}")
            raise
    
    async def get_social_feed(self, user_id: str, limit: int = 20) -> List[Dict[str, Any]]:
        """Get social feed"""
        try:
            response = self.client.table('social_posts').select('*, profiles(*)').order('created_at', desc=True).limit(limit).execute()
            return response.data
        except Exception as e:
            logger.error(f"Error getting social feed: {str(e)}")
            raise

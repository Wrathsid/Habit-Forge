"""
Social router for social features
"""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime
import logging

from database.supabase_client import SupabaseClient

logger = logging.getLogger(__name__)
router = APIRouter()

# Pydantic models
class SocialPostCreate(BaseModel):
    content: str
    image_url: Optional[str] = None
    tags: Optional[List[str]] = []

class PostCommentCreate(BaseModel):
    content: str

@router.get("/insights/{user_id}", response_model=Dict[str, Any])
async def get_social_insights(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get social insights for a user"""
    try:
        friends = await supabase.get_friends(user_id)
        social_feed = await supabase.get_social_feed(user_id)
        
        return {
            "total_friends": len(friends),
            "recent_posts": len(social_feed),
            "social_score": min(len(friends) * 10 + len(social_feed) * 5, 100),
            "insights": [
                f"You have {len(friends)} friends",
                f"Recent activity: {len(social_feed)} posts",
                "Social engagement helps maintain habits"
            ]
        }
    except Exception as e:
        logger.error(f"Error getting social insights: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve social insights"
        )

@router.get("/friends/{user_id}", response_model=List[Dict[str, Any]])
async def get_friends(
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get friends for a user"""
    try:
        friends = await supabase.get_friends(user_id)
        return friends
    except Exception as e:
        logger.error(f"Error getting friends: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve friends"
        )

@router.post("/friends/{user_id}/request")
async def send_friend_request(
    user_id: str,
    friend_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Send a friend request"""
    try:
        friend_data = {
            'user_id': user_id,
            'friend_id': friend_id,
            'status': 'pending',
            'created_at': datetime.now().isoformat()
        }
        
        response = supabase.client.table('friends').insert(friend_data).execute()
        return {"message": "Friend request sent successfully"}
    except Exception as e:
        logger.error(f"Error sending friend request: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send friend request"
        )

@router.get("/feed/{user_id}", response_model=List[Dict[str, Any]])
async def get_social_feed(
    user_id: str,
    limit: int = 20,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Get social feed"""
    try:
        social_feed = await supabase.get_social_feed(user_id, limit)
        return social_feed
    except Exception as e:
        logger.error(f"Error getting social feed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve social feed"
        )

@router.post("/posts/{user_id}", response_model=Dict[str, Any])
async def create_social_post(
    user_id: str,
    post: SocialPostCreate,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Create a social post"""
    try:
        post_data = post.dict()
        post_data['user_id'] = user_id
        post_data['created_at'] = datetime.now().isoformat()
        
        new_post = await supabase.create_social_post(post_data)
        return new_post
    except Exception as e:
        logger.error(f"Error creating social post: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create social post"
        )

@router.post("/posts/{post_id}/like/{user_id}")
async def like_post(
    post_id: str,
    user_id: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Like a post"""
    try:
        like_data = {
            'post_id': post_id,
            'user_id': user_id,
            'created_at': datetime.now().isoformat()
        }
        
        response = supabase.client.table('post_likes').upsert(like_data).execute()
        return {"message": "Post liked successfully"}
    except Exception as e:
        logger.error(f"Error liking post: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to like post"
        )

@router.post("/posts/{post_id}/comment/{user_id}", response_model=Dict[str, Any])
async def comment_on_post(
    post_id: str,
    user_id: str,
    comment: PostCommentCreate,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Comment on a post"""
    try:
        comment_data = comment.dict()
        comment_data['post_id'] = post_id
        comment_data['user_id'] = user_id
        comment_data['created_at'] = datetime.now().isoformat()
        
        response = supabase.client.table('post_comments').insert(comment_data).execute()
        return response.data[0] if response.data else {}
    except Exception as e:
        logger.error(f"Error commenting on post: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to comment on post"
        )

@router.post("/challenges/group")
async def create_group_challenge(
    user_id: str,
    name: str,
    description: str,
    habit_ids: List[str],
    start_date: str,
    end_date: str,
    supabase: SupabaseClient = Depends(lambda: SupabaseClient())
):
    """Create a group challenge"""
    try:
        challenge_data = {
            'creator_id': user_id,
            'title': name,
            'description': description,
            'challenge_type': 'custom',
            'target_value': len(habit_ids),
            'start_date': start_date,
            'end_date': end_date,
            'is_public': True,
            'created_at': datetime.now().isoformat()
        }
        
        response = supabase.client.table('challenges').insert(challenge_data).execute()
        return response.data[0] if response.data else {}
    except Exception as e:
        logger.error(f"Error creating group challenge: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create group challenge"
        )

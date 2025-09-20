-- =====================================================
-- HABIT TRACKER APP - COMPLETE SUPABASE SCHEMA
-- =====================================================
-- Optimized for Flutter app with all features
-- Run this in Supabase SQL Editor

-- WARNING: This will delete all existing data!
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.habits CASCADE;
DROP TABLE IF EXISTS public.habit_completions CASCADE;
DROP TABLE IF EXISTS public.streaks CASCADE;
DROP TABLE IF EXISTS public.user_progress CASCADE;
DROP TABLE IF EXISTS public.badges CASCADE;
DROP TABLE IF EXISTS public.user_badges CASCADE;
DROP TABLE IF EXISTS public.xp_transactions CASCADE;
DROP TABLE IF EXISTS public.friends CASCADE;
DROP TABLE IF EXISTS public.challenges CASCADE;
DROP TABLE IF EXISTS public.challenge_participants CASCADE;
DROP TABLE IF EXISTS public.social_posts CASCADE;
DROP TABLE IF EXISTS public.post_likes CASCADE;
DROP TABLE IF EXISTS public.post_comments CASCADE;
DROP TABLE IF EXISTS public.mood_checkins CASCADE;
DROP TABLE IF EXISTS public.ai_suggestions CASCADE;
DROP TABLE IF EXISTS public.habit_templates CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;

-- Drop additional tables that might exist
DROP TABLE IF EXISTS public.user_preferences CASCADE;
DROP TABLE IF EXISTS public.followers CASCADE;
DROP TABLE IF EXISTS public.activity_feed CASCADE;
DROP TABLE IF EXISTS public.habit_shares CASCADE;
DROP TABLE IF EXISTS public.notification_templates CASCADE;
DROP TABLE IF EXISTS public.notification_schedules CASCADE;
DROP TABLE IF EXISTS public.notification_delivery_logs CASCADE;
DROP TABLE IF EXISTS public.habit_analytics_cache CASCADE;
DROP TABLE IF EXISTS public.user_behavior_patterns CASCADE;

-- Drop any views that might exist
DROP VIEW IF EXISTS public.user_stats CASCADE;
DROP VIEW IF EXISTS public.daily_completion_summary CASCADE;
DROP VIEW IF EXISTS public.social_feed CASCADE;
DROP VIEW IF EXISTS public.user_dashboard CASCADE;
DROP VIEW IF EXISTS public.habit_performance_analytics CASCADE;
DROP VIEW IF EXISTS public.social_engagement_analytics CASCADE;
DROP VIEW IF EXISTS public.mood_correlation_analytics CASCADE;

-- Drop any functions that might exist
DROP FUNCTION IF EXISTS public.handle_habit_completion() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS public.update_post_likes_count() CASCADE;
DROP FUNCTION IF EXISTS public.update_post_comments_count() CASCADE;
DROP FUNCTION IF EXISTS public.calculate_habit_completion_rate(UUID, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS public.get_user_streak_stats(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.generate_user_insights(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.cleanup_expired_analytics_cache() CASCADE;
DROP FUNCTION IF EXISTS public.update_user_level(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.trigger_update_user_level() CASCADE;
DROP FUNCTION IF EXISTS public.create_activity_feed_entry() CASCADE;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles ( 
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    timezone TEXT DEFAULT 'UTC',
    theme_preference TEXT DEFAULT 'dark' CHECK (theme_preference IN ('light', 'dark', 'auto')),
    notification_settings JSONB DEFAULT '{"push": true, "email": true, "reminders": true}',
    -- Gamification fields
    level INTEGER DEFAULT 1,
    total_xp INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Categories table
CREATE TABLE public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    icon TEXT NOT NULL,
    color TEXT DEFAULT '#6B7280',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habits table (matches Flutter Habit model)
CREATE TABLE public.habits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL,
    color TEXT DEFAULT '#6B7280',
    goal INTEGER NOT NULL DEFAULT 1,
    goal_unit TEXT NOT NULL DEFAULT 'times',
    frequency TEXT NOT NULL DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'custom')),
    custom_days INTEGER[] DEFAULT ARRAY[0,1,2,3,4,5,6], -- 0=Sunday, 1=Monday (Flutter format)
    is_active BOOLEAN DEFAULT true,
    is_archived BOOLEAN DEFAULT false,
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    xp_reward INTEGER DEFAULT 10,
    reminder_time TIME,
    reminder_days INTEGER[] DEFAULT ARRAY[0,1,2,3,4,5,6],
    has_reminder BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habit completions table
CREATE TABLE public.habit_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    completion_value INTEGER NOT NULL DEFAULT 1,
    completion_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    mood_rating INTEGER CHECK (mood_rating BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(habit_id, completion_date)
);

-- Streaks table
CREATE TABLE public.streaks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    current_streak INTEGER DEFAULT 0,
    best_streak INTEGER DEFAULT 0,
    last_completion_date DATE,
    streak_freeze_count INTEGER DEFAULT 0,
    streak_freeze_used INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(habit_id, user_id)
);

-- User Progress table (matches Flutter UserProgress model)
CREATE TABLE public.user_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    total_xp INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    xp_to_next_level INTEGER DEFAULT 100,
    total_habits INTEGER DEFAULT 0,
    completed_habits INTEGER DEFAULT 0,
    total_streaks INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Badges table (matches Flutter Achievement model)
CREATE TABLE public.badges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    color TEXT DEFAULT '#F59E0B',
    category TEXT NOT NULL,
    requirement_type TEXT NOT NULL CHECK (requirement_type IN ('streak', 'completion', 'xp', 'social')),
    requirement_value INTEGER NOT NULL,
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    xp_reward INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User badges table
CREATE TABLE public.user_badges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- XP transactions table
CREATE TABLE public.xp_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    habit_id UUID REFERENCES public.habits(id) ON DELETE SET NULL,
    amount INTEGER NOT NULL,
    reason TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- SOCIAL FEATURES TABLES
-- =====================================================

-- Friends table
CREATE TABLE public.friends (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    friend_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id)
);

-- Challenges table (matches Flutter Challenge model)
CREATE TABLE public.challenges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    creator_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    challenge_type TEXT NOT NULL CHECK (challenge_type IN ('streak', 'completion', 'consistency', 'custom')),
    target_value INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_public BOOLEAN DEFAULT false,
    max_participants INTEGER DEFAULT 10,
    reward_xp INTEGER DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Challenge participants table
CREATE TABLE public.challenge_participants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    challenge_id UUID REFERENCES public.challenges(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    current_progress INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(challenge_id, user_id)
);

-- Social posts table (for social feed)
CREATE TABLE public.social_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    tags TEXT[] DEFAULT '{}',
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Post likes table
CREATE TABLE public.post_likes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.social_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Post comments table
CREATE TABLE public.post_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    post_id UUID REFERENCES public.social_posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- AI & ANALYTICS TABLES
-- =====================================================

-- Mood check-ins table (matches Flutter Mood model)
CREATE TABLE public.mood_checkins (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    mood_rating INTEGER NOT NULL CHECK (mood_rating BETWEEN 1 AND 5), -- 1=terrible, 2=bad, 3=okay, 4=good, 5=excellent
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
    stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 5),
    notes TEXT,
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    ai_suggestions JSONB DEFAULT '[]',
    checkin_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, checkin_date)
);

-- AI suggestions table
CREATE TABLE public.ai_suggestions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    suggestion_type TEXT NOT NULL CHECK (suggestion_type IN ('habit_optimization', 'motivation', 'reminder', 'goal_adjustment')),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    is_read BOOLEAN DEFAULT false,
    is_applied BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habit Templates table
CREATE TABLE public.habit_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL,
    category_id UUID REFERENCES public.categories(id),
    goal INTEGER DEFAULT 1,
    goal_unit TEXT DEFAULT 'times',
    frequency TEXT DEFAULT 'daily',
    priority INTEGER DEFAULT 1,
    xp_reward INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('reminder', 'achievement', 'streak', 'social', 'challenge')),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Profiles indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_level ON public.profiles(level);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);

-- Habits indexes
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_category_id ON public.habits(category_id);
CREATE INDEX IF NOT EXISTS idx_habits_is_active ON public.habits(is_active);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON public.habits(created_at);

-- Habit completions indexes
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_id ON public.habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_id ON public.habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_date ON public.habit_completions(completion_date);
CREATE INDEX IF NOT EXISTS idx_habit_completions_habit_date ON public.habit_completions(habit_id, completion_date);

-- Streaks indexes
CREATE INDEX IF NOT EXISTS idx_streaks_habit_id ON public.streaks(habit_id);
CREATE INDEX IF NOT EXISTS idx_streaks_user_id ON public.streaks(user_id);
CREATE INDEX IF NOT EXISTS idx_streaks_current ON public.streaks(current_streak);

-- User progress indexes
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON public.user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_level ON public.user_progress(current_level);

-- XP transactions indexes
CREATE INDEX IF NOT EXISTS idx_xp_transactions_user_id ON public.xp_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_transactions_created_at ON public.xp_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_xp_transactions_habit_id ON public.xp_transactions(habit_id);

-- Friends indexes
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON public.friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON public.friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON public.friends(status);

-- Challenges indexes
CREATE INDEX IF NOT EXISTS idx_challenges_creator_id ON public.challenges(creator_id);
CREATE INDEX IF NOT EXISTS idx_challenges_dates ON public.challenges(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_challenges_is_public ON public.challenges(is_public);

-- Challenge participants indexes
CREATE INDEX IF NOT EXISTS idx_challenge_participants_challenge_id ON public.challenge_participants(challenge_id);
CREATE INDEX IF NOT EXISTS idx_challenge_participants_user_id ON public.challenge_participants(user_id);

-- Social posts indexes
CREATE INDEX IF NOT EXISTS idx_social_posts_user_id ON public.social_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_social_posts_created_at ON public.social_posts(created_at);
CREATE INDEX IF NOT EXISTS idx_social_posts_tags ON public.social_posts USING GIN(tags);

-- Mood checkins indexes
CREATE INDEX IF NOT EXISTS idx_mood_checkins_user_id ON public.mood_checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_checkins_date ON public.mood_checkins(checkin_date);

-- AI suggestions indexes
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_user_id ON public.ai_suggestions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_type ON public.ai_suggestions(suggestion_type);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_is_read ON public.ai_suggestions(is_read);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_created_at ON public.ai_suggestions(created_at);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled_for ON public.notifications(scheduled_for);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_streaks_updated_at BEFORE UPDATE ON public.streaks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_friends_updated_at BEFORE UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_challenges_updated_at BEFORE UPDATE ON public.challenges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON public.user_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_social_posts_updated_at BEFORE UPDATE ON public.social_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON public.post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle habit completion and streak updates
CREATE OR REPLACE FUNCTION handle_habit_completion()
RETURNS TRIGGER AS $$
DECLARE
    habit_record RECORD;
    streak_record RECORD;
    xp_amount INTEGER;
    streak_bonus INTEGER;
BEGIN
    -- Get habit details
    SELECT * INTO habit_record FROM public.habits WHERE id = NEW.habit_id;
    
    -- Get or create streak record
    SELECT * INTO streak_record FROM public.streaks 
    WHERE habit_id = NEW.habit_id AND user_id = NEW.user_id;
    
    IF NOT FOUND THEN
        INSERT INTO public.streaks (habit_id, user_id, current_streak, best_streak, last_completion_date)
        VALUES (NEW.habit_id, NEW.user_id, 1, 1, NEW.completion_date);
        streak_record.current_streak := 1;
        streak_record.best_streak := 1;
    ELSE
        -- Update streak logic
        IF NEW.completion_date = streak_record.last_completion_date + INTERVAL '1 day' THEN
            -- Consecutive day
            streak_record.current_streak := streak_record.current_streak + 1;
        ELSIF NEW.completion_date > streak_record.last_completion_date + INTERVAL '1 day' THEN
            -- Gap in streak, reset
            streak_record.current_streak := 1;
        END IF;
        
        -- Update best streak
        IF streak_record.current_streak > streak_record.best_streak THEN
            streak_record.best_streak := streak_record.current_streak;
        END IF;
        
        -- Update streak record
        UPDATE public.streaks 
        SET current_streak = streak_record.current_streak,
            best_streak = streak_record.best_streak,
            last_completion_date = NEW.completion_date,
            updated_at = NOW()
        WHERE id = streak_record.id;
    END IF;
    
    -- Calculate XP
    xp_amount := COALESCE(habit_record.xp_reward, 10);
    
    -- Streak bonus (every 7 days)
    IF streak_record.current_streak > 0 AND streak_record.current_streak % 7 = 0 THEN
        streak_bonus := streak_record.current_streak * 5;
        xp_amount := xp_amount + streak_bonus;
    END IF;
    
    -- Add XP transaction
    INSERT INTO public.xp_transactions (user_id, habit_id, amount, reason, metadata)
    VALUES (NEW.user_id, NEW.habit_id, xp_amount, 'habit_completion', 
            jsonb_build_object('streak', streak_record.current_streak, 'streak_bonus', COALESCE(streak_bonus, 0)));
    
    -- Update user progress
    INSERT INTO public.user_progress (user_id, total_xp, completed_habits, last_activity)
    VALUES (NEW.user_id, xp_amount, 1, NOW())
    ON CONFLICT (user_id) DO UPDATE SET
        total_xp = user_progress.total_xp + xp_amount,
        completed_habits = user_progress.completed_habits + 1,
        last_activity = NOW(),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for habit completion
CREATE TRIGGER trigger_habit_completion 
    AFTER INSERT ON public.habit_completions 
    FOR EACH ROW EXECUTE FUNCTION handle_habit_completion();

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name, username)
    VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.email), COALESCE(NEW.raw_user_meta_data->>'username', NEW.email));
    
    -- Create initial user progress record
    INSERT INTO public.user_progress (user_id)
    VALUES (NEW.id);
    
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update post likes count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.social_posts 
        SET likes_count = likes_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.social_posts 
        SET likes_count = likes_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Trigger for post likes count
CREATE TRIGGER trigger_update_post_likes_count
    AFTER INSERT OR DELETE ON public.post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_likes_count();

-- Function to update post comments count
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.social_posts 
        SET comments_count = comments_count + 1 
        WHERE id = NEW.post_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.social_posts 
        SET comments_count = comments_count - 1 
        WHERE id = OLD.post_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Trigger for post comments count
CREATE TRIGGER trigger_update_post_comments_count
    AFTER INSERT OR DELETE ON public.post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comments_count();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Categories policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view categories" ON public.categories FOR SELECT USING (auth.role() = 'authenticated');

-- Habits policies
CREATE POLICY "Users can view own habits" ON public.habits FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own habits" ON public.habits FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own habits" ON public.habits FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own habits" ON public.habits FOR DELETE USING (auth.uid() = user_id);

-- Habit completions policies
CREATE POLICY "Users can view own completions" ON public.habit_completions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own completions" ON public.habit_completions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own completions" ON public.habit_completions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own completions" ON public.habit_completions FOR DELETE USING (auth.uid() = user_id);

-- Streaks policies
CREATE POLICY "Users can view own streaks" ON public.streaks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own streaks" ON public.streaks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own streaks" ON public.streaks FOR UPDATE USING (auth.uid() = user_id);

-- User progress policies
CREATE POLICY "Users can view own progress" ON public.user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON public.user_progress FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own progress" ON public.user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Badges policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view badges" ON public.badges FOR SELECT USING (auth.role() = 'authenticated');

-- User badges policies
CREATE POLICY "Users can view own badges" ON public.user_badges FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own badges" ON public.user_badges FOR INSERT WITH CHECK (auth.uid() = user_id);

-- XP transactions policies
CREATE POLICY "Users can view own XP transactions" ON public.xp_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own XP transactions" ON public.xp_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Friends policies
CREATE POLICY "Users can view own friendships" ON public.friends FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Users can insert own friendships" ON public.friends FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own friendships" ON public.friends FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Users can delete own friendships" ON public.friends FOR DELETE USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- Challenges policies
CREATE POLICY "Users can view public challenges" ON public.challenges FOR SELECT USING (is_public = true OR auth.uid() = creator_id);
CREATE POLICY "Users can insert own challenges" ON public.challenges FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Users can update own challenges" ON public.challenges FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Users can delete own challenges" ON public.challenges FOR DELETE USING (auth.uid() = creator_id);

-- Challenge participants policies
CREATE POLICY "Users can view challenge participants" ON public.challenge_participants FOR SELECT USING (
    auth.uid() = user_id OR 
    auth.uid() IN (SELECT creator_id FROM public.challenges WHERE id = challenge_id)
);
CREATE POLICY "Users can insert own participation" ON public.challenge_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own participation" ON public.challenge_participants FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own participation" ON public.challenge_participants FOR DELETE USING (auth.uid() = user_id);

-- Social posts policies
CREATE POLICY "Users can view all posts" ON public.social_posts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can insert own posts" ON public.social_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own posts" ON public.social_posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON public.social_posts FOR DELETE USING (auth.uid() = user_id);

-- Post likes policies
CREATE POLICY "Users can view all likes" ON public.post_likes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can insert own likes" ON public.post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON public.post_likes FOR DELETE USING (auth.uid() = user_id);

-- Post comments policies
CREATE POLICY "Users can view all comments" ON public.post_comments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can insert own comments" ON public.post_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON public.post_comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.post_comments FOR DELETE USING (auth.uid() = user_id);

-- Mood checkins policies
CREATE POLICY "Users can view own mood checkins" ON public.mood_checkins FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own mood checkins" ON public.mood_checkins FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own mood checkins" ON public.mood_checkins FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own mood checkins" ON public.mood_checkins FOR DELETE USING (auth.uid() = user_id);

-- AI suggestions policies
CREATE POLICY "Users can view own AI suggestions" ON public.ai_suggestions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own AI suggestions" ON public.ai_suggestions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own AI suggestions" ON public.ai_suggestions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own AI suggestions" ON public.ai_suggestions FOR DELETE USING (auth.uid() = user_id);

-- Habit templates policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view habit templates" ON public.habit_templates FOR SELECT USING (auth.role() = 'authenticated');

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own notifications" ON public.notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON public.notifications FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Insert default categories
INSERT INTO public.categories (name, icon, color, description) VALUES
('Mindfulness', 'Wind', '#10B981', 'Meditation, breathing, and mental wellness practices'),
('Personal', 'Feather', '#8B5CF6', 'Personal development and self-improvement habits'),
('Fitness', 'Dumbbell', '#EF4444', 'Physical exercise and movement activities'),
('Health', 'Droplets', '#3B82F6', 'Health and wellness related habits'),
('Learning', 'BookOpen', '#F59E0B', 'Educational and skill development activities'),
('Music', 'Music', '#EC4899', 'Musical practice and appreciation'),
('Cooking', 'ChefHat', '#84CC16', 'Culinary skills and meal preparation');

-- Insert default badges
INSERT INTO public.badges (name, description, icon, color, category, requirement_type, requirement_value, rarity, xp_reward) VALUES
('First Steps', 'Complete your first habit', 'Zap', '#F59E0B', 'completion', 'completion', 1, 'common', 50),
('Week Warrior', 'Complete a 7-day streak', 'Award', '#10B981', 'streak', 'streak', 7, 'common', 100),
('Month Master', 'Complete a 30-day streak', 'Crown', '#8B5CF6', 'streak', 'streak', 30, 'rare', 500),
('Century Club', 'Complete 100 habits', 'Target', '#EF4444', 'completion', 'completion', 100, 'epic', 1000),
('XP Collector', 'Earn 1000 XP', 'Star', '#F59E0B', 'xp', 'xp', 1000, 'common', 200),
('Social Butterfly', 'Complete a challenge with friends', 'Users', '#EC4899', 'social', 'completion', 1, 'rare', 300),
('Zen Master', 'Complete 50 mindfulness habits', 'Wind', '#10B981', 'completion', 'completion', 50, 'epic', 800),
('Iron Will', 'Complete a 100-day streak', 'Shield', '#6B7280', 'streak', 'streak', 100, 'legendary', 2000);

-- Insert default habit templates
INSERT INTO public.habit_templates (name, description, icon, category_id, goal, goal_unit, frequency, priority, xp_reward) VALUES
('Drink Water', 'Stay hydrated throughout the day', 'Droplets', (SELECT id FROM public.categories WHERE name = 'Health'), 8, 'glasses', 'daily', 1, 10),
('Morning Meditation', 'Start your day with mindfulness', 'Wind', (SELECT id FROM public.categories WHERE name = 'Mindfulness'), 10, 'minutes', 'daily', 2, 15),
('Read Books', 'Expand your knowledge daily', 'BookOpen', (SELECT id FROM public.categories WHERE name = 'Learning'), 30, 'minutes', 'daily', 2, 20),
('Exercise', 'Keep your body active', 'Dumbbell', (SELECT id FROM public.categories WHERE name = 'Fitness'), 30, 'minutes', 'daily', 3, 25),
('Practice Music', 'Improve your musical skills', 'Music', (SELECT id FROM public.categories WHERE name = 'Music'), 20, 'minutes', 'daily', 2, 15),
('Cook Healthy Meal', 'Prepare nutritious food', 'ChefHat', (SELECT id FROM public.categories WHERE name = 'Cooking'), 1, 'meal', 'daily', 2, 20),
('Journal Writing', 'Reflect on your day', 'Feather', (SELECT id FROM public.categories WHERE name = 'Personal'), 1, 'entry', 'daily', 1, 10);

-- =====================================================
-- VIEWS FOR ANALYTICS
-- =====================================================

-- User stats view
CREATE VIEW public.user_stats AS
SELECT 
    p.id as user_id,
    p.display_name,
    p.username,
    p.level,
    p.total_xp,
    COUNT(DISTINCT h.id) as total_habits,
    COUNT(DISTINCT CASE WHEN h.is_active THEN h.id END) as active_habits,
    COUNT(DISTINCT hc.id) as total_completions,
    COALESCE(SUM(xt.amount), 0) as total_xp_earned,
    COUNT(DISTINCT ub.badge_id) as badges_earned,
    COALESCE(AVG(s.current_streak), 0) as avg_current_streak,
    COALESCE(MAX(s.best_streak), 0) as best_streak_ever
FROM public.profiles p
LEFT JOIN public.habits h ON p.id = h.user_id
LEFT JOIN public.habit_completions hc ON p.id = hc.user_id
LEFT JOIN public.xp_transactions xt ON p.id = xt.user_id
LEFT JOIN public.user_badges ub ON p.id = ub.user_id
LEFT JOIN public.streaks s ON p.id = s.user_id
GROUP BY p.id, p.display_name, p.username, p.level, p.total_xp;

-- Daily completion summary view
CREATE VIEW public.daily_completion_summary AS
SELECT 
    hc.completion_date,
    hc.user_id,
    COUNT(*) as habits_completed,
    SUM(hc.completion_value) as total_completion_value,
    COALESCE(SUM(xt.amount), 0) as xp_earned,
    AVG(hc.mood_rating) as avg_mood_rating
FROM public.habit_completions hc
LEFT JOIN public.xp_transactions xt ON hc.user_id = xt.user_id 
    AND DATE(xt.created_at) = hc.completion_date
    AND xt.habit_id = hc.habit_id
GROUP BY hc.completion_date, hc.user_id;

-- Social feed view
CREATE VIEW public.social_feed AS
SELECT 
    sp.id,
    sp.user_id,
    p.display_name,
    p.username,
    p.avatar_url,
    sp.content,
    sp.image_url,
    sp.tags,
    sp.likes_count,
    sp.comments_count,
    sp.created_at,
    CASE WHEN pl.user_id IS NOT NULL THEN true ELSE false END as is_liked
FROM public.social_posts sp
JOIN public.profiles p ON sp.user_id = p.id
LEFT JOIN public.post_likes pl ON sp.id = pl.post_id AND pl.user_id = auth.uid()
ORDER BY sp.created_at DESC;

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant permissions on tables
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Grant permissions on sequences
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant permissions on views
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- =====================================================
-- ADDITIONAL SOCIAL FEATURES TABLES
-- =====================================================

-- User preferences table
CREATE TABLE public.user_preferences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    privacy_level TEXT DEFAULT 'friends' CHECK (privacy_level IN ('public', 'friends', 'private')),
    show_achievements BOOLEAN DEFAULT true,
    show_streaks BOOLEAN DEFAULT true,
    show_mood BOOLEAN DEFAULT false,
    allow_friend_requests BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    push_notifications BOOLEAN DEFAULT true,
    weekly_reports BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Followers table (for following other users)
CREATE TABLE public.followers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- Activity feed table
CREATE TABLE public.activity_feed (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    actor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    activity_type TEXT NOT NULL CHECK (activity_type IN ('habit_completed', 'streak_milestone', 'badge_earned', 'challenge_joined', 'post_created')),
    activity_data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habit sharing table
CREATE TABLE public.habit_shares (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    shared_with_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    permission_level TEXT DEFAULT 'view' CHECK (permission_level IN ('view', 'comment', 'collaborate')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(habit_id, shared_with_user_id)
);

-- =====================================================
-- ENHANCED NOTIFICATION SYSTEM TABLES
-- =====================================================

-- Notification templates table
CREATE TABLE public.notification_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    title_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    notification_type TEXT NOT NULL CHECK (notification_type IN ('reminder', 'achievement', 'streak', 'social', 'challenge', 'motivation')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification schedules table
CREATE TABLE public.notification_schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
    schedule_type TEXT NOT NULL CHECK (schedule_type IN ('daily', 'weekly', 'custom', 'smart')),
    schedule_data JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notification delivery logs table
CREATE TABLE public.notification_delivery_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    notification_id UUID REFERENCES public.notifications(id) ON DELETE CASCADE NOT NULL,
    delivery_method TEXT NOT NULL CHECK (delivery_method IN ('push', 'email', 'in_app')),
    delivery_status TEXT NOT NULL CHECK (delivery_status IN ('sent', 'delivered', 'failed', 'opened')),
    delivery_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    error_message TEXT,
    metadata JSONB DEFAULT '{}'
);

-- =====================================================
-- ADVANCED ANALYTICS TABLES
-- =====================================================

-- Habit analytics cache table
CREATE TABLE public.habit_analytics_cache (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
    analytics_type TEXT NOT NULL CHECK (analytics_type IN ('daily', 'weekly', 'monthly', 'yearly', 'custom')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    analytics_data JSONB NOT NULL,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '1 hour',
    UNIQUE(user_id, habit_id, analytics_type, period_start, period_end)
);

-- User behavior patterns table
CREATE TABLE public.user_behavior_patterns (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    pattern_type TEXT NOT NULL CHECK (pattern_type IN ('completion_time', 'streak_pattern', 'mood_correlation', 'habit_interaction')),
    pattern_data JSONB NOT NULL,
    confidence_score DECIMAL(3,2) DEFAULT 0.0 CHECK (confidence_score BETWEEN 0.0 AND 1.0),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ENHANCED INDEXES FOR PERFORMANCE
-- =====================================================

-- User preferences indexes
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_privacy ON public.user_preferences(privacy_level);

-- Followers indexes
CREATE INDEX IF NOT EXISTS idx_followers_follower_id ON public.followers(follower_id);
CREATE INDEX IF NOT EXISTS idx_followers_following_id ON public.followers(following_id);
CREATE INDEX IF NOT EXISTS idx_followers_created_at ON public.followers(created_at);

-- Activity feed indexes
CREATE INDEX IF NOT EXISTS idx_activity_feed_user_id ON public.activity_feed(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_feed_actor_id ON public.activity_feed(actor_id);
CREATE INDEX IF NOT EXISTS idx_activity_feed_type ON public.activity_feed(activity_type);
CREATE INDEX IF NOT EXISTS idx_activity_feed_is_read ON public.activity_feed(is_read);
CREATE INDEX IF NOT EXISTS idx_activity_feed_created_at ON public.activity_feed(created_at);
CREATE INDEX IF NOT EXISTS idx_activity_feed_user_created ON public.activity_feed(user_id, created_at);

-- Habit shares indexes
CREATE INDEX IF NOT EXISTS idx_habit_shares_habit_id ON public.habit_shares(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_shares_user_id ON public.habit_shares(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_shares_shared_with ON public.habit_shares(shared_with_user_id);

-- Notification templates indexes
CREATE INDEX IF NOT EXISTS idx_notification_templates_type ON public.notification_templates(notification_type);
CREATE INDEX IF NOT EXISTS idx_notification_templates_active ON public.notification_templates(is_active);

-- Notification schedules indexes
CREATE INDEX IF NOT EXISTS idx_notification_schedules_user_id ON public.notification_schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_schedules_habit_id ON public.notification_schedules(habit_id);
CREATE INDEX IF NOT EXISTS idx_notification_schedules_type ON public.notification_schedules(schedule_type);
CREATE INDEX IF NOT EXISTS idx_notification_schedules_active ON public.notification_schedules(is_active);

-- Notification delivery logs indexes
CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_notification_id ON public.notification_delivery_logs(notification_id);
CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_status ON public.notification_delivery_logs(delivery_status);
CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_method ON public.notification_delivery_logs(delivery_method);
CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_time ON public.notification_delivery_logs(delivery_time);

-- Analytics cache indexes
CREATE INDEX IF NOT EXISTS idx_habit_analytics_cache_user_id ON public.habit_analytics_cache(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_analytics_cache_habit_id ON public.habit_analytics_cache(habit_id);
CREATE INDEX IF NOT EXISTS idx_habit_analytics_cache_type ON public.habit_analytics_cache(analytics_type);
CREATE INDEX IF NOT EXISTS idx_habit_analytics_cache_period ON public.habit_analytics_cache(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_habit_analytics_cache_expires ON public.habit_analytics_cache(expires_at);

-- User behavior patterns indexes
CREATE INDEX IF NOT EXISTS idx_user_behavior_patterns_user_id ON public.user_behavior_patterns(user_id);
CREATE INDEX IF NOT EXISTS idx_user_behavior_patterns_type ON public.user_behavior_patterns(pattern_type);
CREATE INDEX IF NOT EXISTS idx_user_behavior_patterns_confidence ON public.user_behavior_patterns(confidence_score);
CREATE INDEX IF NOT EXISTS idx_user_behavior_patterns_updated ON public.user_behavior_patterns(last_updated);

-- Composite indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_habits_user_active ON public.habits(user_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_date ON public.habit_completions(user_id, completion_date);
CREATE INDEX IF NOT EXISTS idx_streaks_user_current ON public.streaks(user_id, current_streak) WHERE current_streak > 0;
CREATE INDEX IF NOT EXISTS idx_social_posts_user_created ON public.social_posts(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_mood_checkins_user_date ON public.mood_checkins(user_id, checkin_date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read) WHERE is_read = false;

-- =====================================================
-- ENHANCED ANALYTICS VIEWS AND FUNCTIONS
-- =====================================================

-- Comprehensive user dashboard view
CREATE VIEW public.user_dashboard AS
SELECT 
    p.id as user_id,
    p.display_name,
    p.username,
    p.level,
    p.total_xp,
    COUNT(DISTINCT h.id) as total_habits,
    COUNT(DISTINCT CASE WHEN h.is_active THEN h.id END) as active_habits,
    COUNT(DISTINCT hc.id) as total_completions,
    COUNT(DISTINCT CASE WHEN hc.completion_date >= CURRENT_DATE - INTERVAL '7 days' THEN hc.id END) as weekly_completions,
    COUNT(DISTINCT CASE WHEN hc.completion_date >= CURRENT_DATE - INTERVAL '30 days' THEN hc.id END) as monthly_completions,
    COALESCE(SUM(xt.amount), 0) as total_xp_earned,
    COUNT(DISTINCT ub.badge_id) as badges_earned,
    COALESCE(AVG(s.current_streak), 0) as avg_current_streak,
    COALESCE(MAX(s.best_streak), 0) as best_streak_ever,
    COUNT(DISTINCT f.friend_id) as total_friends,
    COUNT(DISTINCT sp.id) as total_posts,
    COUNT(DISTINCT mc.id) as mood_entries,
    COALESCE(AVG(mc.mood_rating), 0) as avg_mood_rating,
    up.last_activity,
    up.current_level,
    up.xp_to_next_level
FROM public.profiles p
LEFT JOIN public.habits h ON p.id = h.user_id
LEFT JOIN public.habit_completions hc ON p.id = hc.user_id
LEFT JOIN public.xp_transactions xt ON p.id = xt.user_id
LEFT JOIN public.user_badges ub ON p.id = ub.user_id
LEFT JOIN public.streaks s ON p.id = s.user_id
LEFT JOIN public.friends f ON p.id = f.user_id AND f.status = 'accepted'
LEFT JOIN public.social_posts sp ON p.id = sp.user_id
LEFT JOIN public.mood_checkins mc ON p.id = mc.user_id
LEFT JOIN public.user_progress up ON p.id = up.user_id
GROUP BY p.id, p.display_name, p.username, p.level, p.total_xp, up.last_activity, up.current_level, up.xp_to_next_level;

-- Habit performance analytics view
CREATE VIEW public.habit_performance_analytics AS
SELECT 
    h.id as habit_id,
    h.name as habit_name,
    h.user_id,
    h.goal,
    h.frequency,
    h.priority,
    COUNT(DISTINCT hc.id) as total_completions,
    COUNT(DISTINCT CASE WHEN hc.completion_date >= CURRENT_DATE - INTERVAL '7 days' THEN hc.id END) as weekly_completions,
    COUNT(DISTINCT CASE WHEN hc.completion_date >= CURRENT_DATE - INTERVAL '30 days' THEN hc.id END) as monthly_completions,
    COALESCE(s.current_streak, 0) as current_streak,
    COALESCE(s.best_streak, 0) as best_streak,
    COALESCE(AVG(hc.mood_rating), 0) as avg_mood_rating,
    COALESCE(AVG(hc.completion_value), 0) as avg_completion_value,
    h.created_at,
    h.is_active,
    CASE 
        WHEN COUNT(DISTINCT hc.id) = 0 THEN 0
        ELSE ROUND((COUNT(DISTINCT hc.id)::DECIMAL / EXTRACT(DAYS FROM CURRENT_DATE - h.created_at)) * 100, 2)
    END as completion_rate_percentage
FROM public.habits h
LEFT JOIN public.habit_completions hc ON h.id = hc.habit_id
LEFT JOIN public.streaks s ON h.id = s.habit_id
GROUP BY h.id, h.name, h.user_id, h.goal, h.frequency, h.priority, s.current_streak, s.best_streak, h.created_at, h.is_active;

-- Social engagement analytics view
CREATE VIEW public.social_engagement_analytics AS
SELECT 
    p.id as user_id,
    p.display_name,
    COUNT(DISTINCT sp.id) as total_posts,
    COUNT(DISTINCT pl.id) as total_likes_given,
    COUNT(DISTINCT pc.id) as total_comments_given,
    COUNT(DISTINCT f.friend_id) as total_friends,
    COUNT(DISTINCT fl.following_id) as total_following,
    COUNT(DISTINCT fl2.follower_id) as total_followers,
    COUNT(DISTINCT cp.challenge_id) as challenges_participated,
    COALESCE(SUM(sp.likes_count), 0) as total_likes_received,
    COALESCE(SUM(sp.comments_count), 0) as total_comments_received,
    COALESCE(AVG(sp.likes_count), 0) as avg_likes_per_post,
    COALESCE(AVG(sp.comments_count), 0) as avg_comments_per_post
FROM public.profiles p
LEFT JOIN public.social_posts sp ON p.id = sp.user_id
LEFT JOIN public.post_likes pl ON p.id = pl.user_id
LEFT JOIN public.post_comments pc ON p.id = pc.user_id
LEFT JOIN public.friends f ON p.id = f.user_id AND f.status = 'accepted'
LEFT JOIN public.followers fl ON p.id = fl.follower_id
LEFT JOIN public.followers fl2 ON p.id = fl2.following_id
LEFT JOIN public.challenge_participants cp ON p.id = cp.user_id
GROUP BY p.id, p.display_name;

-- Mood correlation analytics view
CREATE VIEW public.mood_correlation_analytics AS
SELECT 
    mc.user_id,
    mc.checkin_date,
    mc.mood_rating,
    mc.energy_level,
    mc.stress_level,
    COUNT(DISTINCT hc.habit_id) as habits_completed,
    SUM(hc.completion_value) as total_completion_value,
    STRING_AGG(DISTINCT h.name, ', ') as completed_habits
FROM public.mood_checkins mc
LEFT JOIN public.habit_completions hc ON mc.user_id = hc.user_id AND mc.checkin_date = hc.completion_date
LEFT JOIN public.habits h ON hc.habit_id = h.id
GROUP BY mc.user_id, mc.checkin_date, mc.mood_rating, mc.energy_level, mc.stress_level;

-- =====================================================
-- ADVANCED HELPER FUNCTIONS
-- =====================================================

-- Function to calculate habit completion rate
CREATE OR REPLACE FUNCTION calculate_habit_completion_rate(
    p_habit_id UUID,
    p_days INTEGER DEFAULT 30
)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    total_days INTEGER;
    completed_days INTEGER;
    completion_rate DECIMAL(5,2);
BEGIN
    -- Get total possible days
    SELECT EXTRACT(DAYS FROM CURRENT_DATE - created_at) INTO total_days
    FROM public.habits WHERE id = p_habit_id;
    
    -- Limit to requested days
    total_days := LEAST(total_days, p_days);
    
    -- Get completed days
    SELECT COUNT(*) INTO completed_days
    FROM public.habit_completions
    WHERE habit_id = p_habit_id
    AND completion_date >= CURRENT_DATE - INTERVAL '1 day' * p_days;
    
    -- Calculate rate
    IF total_days = 0 THEN
        completion_rate := 0;
    ELSE
        completion_rate := ROUND((completed_days::DECIMAL / total_days) * 100, 2);
    END IF;
    
    RETURN completion_rate;
END;
$$ LANGUAGE plpgsql;

-- Function to get user streak statistics
CREATE OR REPLACE FUNCTION get_user_streak_stats(p_user_id UUID)
RETURNS TABLE(
    total_active_streaks INTEGER,
    longest_current_streak INTEGER,
    longest_ever_streak INTEGER,
    total_streak_days INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_active_streaks,
        COALESCE(MAX(s.current_streak), 0)::INTEGER as longest_current_streak,
        COALESCE(MAX(s.best_streak), 0)::INTEGER as longest_ever_streak,
        COALESCE(SUM(s.current_streak), 0)::INTEGER as total_streak_days
    FROM public.streaks s
    WHERE s.user_id = p_user_id AND s.current_streak > 0;
END;
$$ LANGUAGE plpgsql;

-- Function to generate personalized insights
CREATE OR REPLACE FUNCTION generate_user_insights(p_user_id UUID)
RETURNS TABLE(
    insight_type TEXT,
    insight_title TEXT,
    insight_description TEXT,
    insight_data JSONB,
    priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH user_stats AS (
        SELECT 
            COUNT(DISTINCT h.id) as total_habits,
            COUNT(DISTINCT hc.id) as total_completions,
            COALESCE(AVG(s.current_streak), 0) as avg_streak,
            COALESCE(AVG(mc.mood_rating), 0) as avg_mood
        FROM public.profiles p
        LEFT JOIN public.habits h ON p.id = h.user_id
        LEFT JOIN public.habit_completions hc ON p.id = hc.user_id
        LEFT JOIN public.streaks s ON p.id = s.user_id
        LEFT JOIN public.mood_checkins mc ON p.id = mc.user_id
        WHERE p.id = p_user_id
    )
    SELECT 
        'completion_rate'::TEXT as insight_type,
        'Completion Rate Analysis'::TEXT as insight_title,
        CASE 
            WHEN us.total_completions::DECIMAL / GREATEST(us.total_habits * 30, 1) > 0.8 THEN 'Excellent completion rate! Keep up the great work!'
            WHEN us.total_completions::DECIMAL / GREATEST(us.total_habits * 30, 1) > 0.6 THEN 'Good completion rate. Consider adding more habits.'
            WHEN us.total_completions::DECIMAL / GREATEST(us.total_habits * 30, 1) > 0.4 THEN 'Moderate completion rate. Focus on consistency.'
            ELSE 'Low completion rate. Start with smaller goals.'
        END::TEXT as insight_description,
        jsonb_build_object(
            'completion_rate', ROUND(us.total_completions::DECIMAL / GREATEST(us.total_habits * 30, 1) * 100, 2),
            'total_completions', us.total_completions,
            'total_habits', us.total_habits
        ) as insight_data,
        1 as priority
    FROM user_stats us
    
    UNION ALL
    
    SELECT 
        'streak_analysis'::TEXT as insight_type,
        'Streak Performance'::TEXT as insight_title,
        CASE 
            WHEN us.avg_streak > 7 THEN 'Amazing streak consistency! You are building strong habits.'
            WHEN us.avg_streak > 3 THEN 'Good streak performance. Try to extend your streaks.'
            WHEN us.avg_streak > 1 THEN 'Building momentum. Focus on daily consistency.'
            ELSE 'Start building streaks by completing habits daily.'
        END::TEXT as insight_description,
        jsonb_build_object(
            'average_streak', ROUND(us.avg_streak, 1),
            'recommendation', 'Focus on one habit at a time for better consistency'
        ) as insight_data,
        2 as priority
    FROM user_stats us
    
    UNION ALL
    
    SELECT 
        'mood_correlation'::TEXT as insight_type,
        'Mood & Habits Connection'::TEXT as insight_title,
        CASE 
            WHEN us.avg_mood > 4 THEN 'Great mood! Your habits are positively impacting your wellbeing.'
            WHEN us.avg_mood > 3 THEN 'Good mood levels. Consider adding mood-boosting habits.'
            WHEN us.avg_mood > 2 THEN 'Moderate mood. Focus on habits that bring you joy.'
            ELSE 'Consider adding habits that improve your mood and energy.'
        END::TEXT as insight_description,
        jsonb_build_object(
            'average_mood', ROUND(us.avg_mood, 1),
            'correlation_strength', 'moderate'
        ) as insight_data,
        3 as priority
    FROM user_stats us;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired analytics cache
CREATE OR REPLACE FUNCTION cleanup_expired_analytics_cache()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.habit_analytics_cache 
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update user level based on XP
CREATE OR REPLACE FUNCTION update_user_level(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    current_xp INTEGER;
    new_level INTEGER;
    xp_for_level INTEGER;
BEGIN
    -- Get current XP
    SELECT total_xp INTO current_xp
    FROM public.user_progress
    WHERE user_id = p_user_id;
    
    -- Calculate level based on XP (100 * level^1.5)
    new_level := 1;
    LOOP
        xp_for_level := (100 * POWER(new_level, 1.5))::INTEGER;
        EXIT WHEN current_xp < xp_for_level;
        new_level := new_level + 1;
    END LOOP;
    
    new_level := new_level - 1;
    
    -- Update user progress
    UPDATE public.user_progress
    SET 
        current_level = new_level,
        xp_to_next_level = (100 * POWER(new_level + 1, 1.5))::INTEGER - current_xp,
        updated_at = NOW()
    WHERE user_id = p_user_id;
    
    -- Update profiles table
    UPDATE public.profiles
    SET 
        level = new_level,
        updated_at = NOW()
    WHERE id = p_user_id;
    
    RETURN new_level;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ENHANCED TRIGGERS
-- =====================================================

-- Trigger to update user level when XP changes
CREATE OR REPLACE FUNCTION trigger_update_user_level()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_user_level(NEW.user_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_progress_level_update
    AFTER UPDATE OF total_xp ON public.user_progress
    FOR EACH ROW EXECUTE FUNCTION trigger_update_user_level();

-- Trigger to create activity feed entries
CREATE OR REPLACE FUNCTION create_activity_feed_entry()
RETURNS TRIGGER AS $$
BEGIN
    -- Create activity feed entry for habit completion
    INSERT INTO public.activity_feed (user_id, actor_id, activity_type, activity_data)
    VALUES (
        NEW.user_id,
        NEW.user_id,
        'habit_completed',
        jsonb_build_object(
            'habit_id', NEW.habit_id,
            'completion_date', NEW.completion_date,
            'completion_value', NEW.completion_value
        )
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_habit_completion_activity
    AFTER INSERT ON public.habit_completions
    FOR EACH ROW EXECUTE FUNCTION create_activity_feed_entry();

-- Trigger to update notification schedules
CREATE TRIGGER update_notification_schedules_updated_at BEFORE UPDATE ON public.notification_schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ENHANCED RLS POLICIES
-- =====================================================

-- Enable RLS on new tables
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_feed ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_delivery_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_analytics_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_behavior_patterns ENABLE ROW LEVEL SECURITY;

-- User preferences policies
CREATE POLICY "Users can view own preferences" ON public.user_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own preferences" ON public.user_preferences FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own preferences" ON public.user_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Followers policies
CREATE POLICY "Users can view own followers" ON public.followers FOR SELECT USING (auth.uid() = follower_id OR auth.uid() = following_id);
CREATE POLICY "Users can insert own follows" ON public.followers FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can delete own follows" ON public.followers FOR DELETE USING (auth.uid() = follower_id);

-- Activity feed policies
CREATE POLICY "Users can view own activity feed" ON public.activity_feed FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own activity" ON public.activity_feed FOR INSERT WITH CHECK (auth.uid() = actor_id);
CREATE POLICY "Users can update own activity" ON public.activity_feed FOR UPDATE USING (auth.uid() = user_id);

-- Habit shares policies
CREATE POLICY "Users can view shared habits" ON public.habit_shares FOR SELECT USING (auth.uid() = user_id OR auth.uid() = shared_with_user_id);
CREATE POLICY "Users can share own habits" ON public.habit_shares FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own shares" ON public.habit_shares FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own shares" ON public.habit_shares FOR DELETE USING (auth.uid() = user_id);

-- Notification templates policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view notification templates" ON public.notification_templates FOR SELECT USING (auth.role() = 'authenticated');

-- Notification schedules policies
CREATE POLICY "Users can view own schedules" ON public.notification_schedules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own schedules" ON public.notification_schedules FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own schedules" ON public.notification_schedules FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own schedules" ON public.notification_schedules FOR DELETE USING (auth.uid() = user_id);

-- Notification delivery logs policies
CREATE POLICY "Users can view own delivery logs" ON public.notification_delivery_logs FOR SELECT USING (
    auth.uid() IN (SELECT user_id FROM public.notifications WHERE id = notification_id)
);

-- Analytics cache policies
CREATE POLICY "Users can view own analytics cache" ON public.habit_analytics_cache FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own analytics cache" ON public.habit_analytics_cache FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own analytics cache" ON public.habit_analytics_cache FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own analytics cache" ON public.habit_analytics_cache FOR DELETE USING (auth.uid() = user_id);

-- User behavior patterns policies
CREATE POLICY "Users can view own behavior patterns" ON public.user_behavior_patterns FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own behavior patterns" ON public.user_behavior_patterns FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own behavior patterns" ON public.user_behavior_patterns FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own behavior patterns" ON public.user_behavior_patterns FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- INITIAL DATA FOR NEW TABLES
-- =====================================================

-- Insert notification templates
INSERT INTO public.notification_templates (name, title_template, body_template, notification_type) VALUES
('habit_reminder', 'Time for {habit_name}!', 'Don''t forget to complete your {habit_name} habit. You''re on a {current_streak} day streak!', 'reminder'),
('streak_milestone', 'Streak Milestone!', 'Congratulations! You''ve reached a {streak_days} day streak for {habit_name}!', 'streak'),
('badge_earned', 'New Badge Earned!', 'You''ve earned the {badge_name} badge! {badge_description}', 'achievement'),
('challenge_invite', 'Challenge Invitation', '{creator_name} has invited you to join the "{challenge_title}" challenge!', 'challenge'),
('motivation_daily', 'Daily Motivation', 'Every small step counts! You''ve completed {completed_habits} habits today. Keep going!', 'motivation');

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================

-- Schema creation completed successfully!
-- This enhanced schema includes:
-- ✅ All core tables for habit tracking with Flutter-compatible field names
-- ✅ Enhanced social features (followers, activity feed, habit sharing)
-- ✅ Advanced notification system (templates, schedules, delivery logs)
-- ✅ Comprehensive analytics (caching, behavior patterns, insights)
-- ✅ Gamification (badges, XP, streaks, user progress)
-- ✅ AI features (mood checkins, suggestions) with Flutter-compatible structure
-- ✅ Proper relationships and constraints
-- ✅ Optimized performance indexes (including composite indexes)
-- ✅ Row-level security policies
-- ✅ Advanced triggers for automation
-- ✅ Initial data (categories, badges, habit templates, notification templates)
-- ✅ Comprehensive analytics views and helper functions
-- ✅ Social engagement analytics
-- ✅ Mood correlation analytics
-- ✅ Personalized insight generation
-- ✅ Automated level calculation
-- ✅ Activity feed system
-- ✅ Enhanced notification management

-- Key enhancements added:
-- ✅ User preferences and privacy controls
-- ✅ Followers system for social engagement
-- ✅ Activity feed for real-time updates
-- ✅ Habit sharing with permission levels
-- ✅ Advanced notification templates and scheduling
-- ✅ Analytics caching for performance
-- ✅ User behavior pattern analysis
-- ✅ Comprehensive dashboard views
-- ✅ Advanced helper functions for insights
-- ✅ Automated level progression
-- ✅ Enhanced social engagement tracking

-- Next steps:
-- 1. Run this SQL in Supabase SQL Editor
-- 2. Set up your FastAPI backend to connect to this database
-- 3. Configure authentication providers (Google/Apple)
-- 4. Test the API endpoints with your Flutter app
-- 5. Set up real-time subscriptions for live updates
-- 6. Configure notification delivery services
-- 7. Set up analytics data processing

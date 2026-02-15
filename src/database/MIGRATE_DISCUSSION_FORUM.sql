-- Migration script to add polymorphic relationship to discussion_forum
-- Run this in your Supabase SQL Editor

-- 1. Add new columns if they don't exist
ALTER TABLE public.discussion_forum 
ADD COLUMN IF NOT EXISTS parent_id bigint,
ADD COLUMN IF NOT EXISTS parent_type text; -- 'LOG' or 'FEATURE'

-- 2. Migrate existing data if needed (optional)
-- If you had log_id, you can move it to parent_id
-- UPDATE public.discussion_forum SET parent_id = log_id, parent_type = 'LOG' WHERE log_id IS NOT NULL;

-- 3. Remove old columns if they exist (clean up)
-- ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS log_id;
-- ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS request_id;

-- 4. Create index for performance
CREATE INDEX IF NOT EXISTS idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);

-- 5. Update RLS Policies to be more generic
DROP POLICY IF EXISTS "Anyone can view comments" ON public.discussion_forum;
CREATE POLICY "Anyone can view comments" 
ON public.discussion_forum FOR SELECT 
TO authenticated 
USING (true);

DROP POLICY IF EXISTS "Users can insert their own comments" ON public.discussion_forum;
CREATE POLICY "Users can insert their own comments" 
ON public.discussion_forum FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

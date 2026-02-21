-- Fix RLS Policies for Logs table to allow Insert/Update
-- Run this in Supabase SQL Editor

-- 1. Enable RLS on logs table (ensure it is on)
ALTER TABLE public.logs ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.logs;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.logs;
DROP POLICY IF EXISTS "Enable update for own logs or editors" ON public.logs;
DROP POLICY IF EXISTS "Enable delete for admins" ON public.logs;

-- 3. Create new policies

-- READ: Allow all authenticated users to read logs
CREATE POLICY "Enable read access for authenticated users" 
ON public.logs FOR SELECT 
TO authenticated 
USING (true);

-- INSERT: Allow all authenticated users to insert logs
CREATE POLICY "Enable insert for authenticated users" 
ON public.logs FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- UPDATE: Allow users to update their own logs OR users with Editor/Admin role
CREATE POLICY "Enable update for own logs or editors" 
ON public.logs FOR UPDATE 
TO authenticated 
USING (
  auth.uid() = reporter_id OR 
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
    AND (role::text = 'Editor' OR role::text = 'Admin' OR role::text = 'Super Admin')
  )
);

-- DELETE: Allow only Admins to delete
CREATE POLICY "Enable delete for admins" 
ON public.logs FOR DELETE 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() 
    AND (role::text = 'Admin' OR role::text = 'Super Admin')
  )
);

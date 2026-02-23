-- FIX: Safe RLS Policy Reset (IDEMPOTENT)
-- Run this in Supabase SQL Editor to fix permissions without "policy already exists" errors

-- 1. feature_requests: Allow EVERYTHING for authenticated users
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.feature_requests;

CREATE POLICY "Enable all access for authenticated users" ON public.feature_requests
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 2. projects: Allow READ access (crucial for foreign keys)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.projects;
CREATE POLICY "Enable read access for authenticated users" ON public.projects
    FOR SELECT TO authenticated USING (true);

-- 3. app_components: Allow READ access (crucial for foreign keys)
ALTER TABLE public.app_components ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.app_components;
CREATE POLICY "Enable read access for authenticated users" ON public.app_components
    FOR SELECT TO authenticated USING (true);

-- 4. profiles: Allow READ access (crucial for foreign keys)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.profiles;
CREATE POLICY "Enable read access for authenticated users" ON public.profiles
    FOR SELECT TO authenticated USING (true);

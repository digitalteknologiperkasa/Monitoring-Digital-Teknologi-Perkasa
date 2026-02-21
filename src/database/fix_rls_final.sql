-- FIX ALL: Comprehensive RLS Policy Fix
-- Run this in Supabase SQL Editor to unblock all feature request operations

-- 1. feature_requests: Allow EVERYTHING for authenticated users (simplest fix)
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.feature_requests;
CREATE POLICY "Enable all access for authenticated users" ON public.feature_requests
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 2. profiles: Allow READ access (crucial for foreign keys)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.profiles;
CREATE POLICY "Enable read access for authenticated users" ON public.profiles
    FOR SELECT TO authenticated USING (true);

-- 3. projects: Allow READ access (crucial for foreign keys)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.projects;
CREATE POLICY "Enable read access for authenticated users" ON public.projects
    FOR SELECT TO authenticated USING (true);

-- 4. app_components: Allow READ access (crucial for foreign keys)
ALTER TABLE public.app_components ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.app_components;
CREATE POLICY "Enable read access for authenticated users" ON public.app_components
    FOR SELECT TO authenticated USING (true);

-- 5. access_roles: Allow READ access
ALTER TABLE public.access_roles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.access_roles;
CREATE POLICY "Enable read access for authenticated users" ON public.access_roles
    FOR SELECT TO authenticated USING (true);

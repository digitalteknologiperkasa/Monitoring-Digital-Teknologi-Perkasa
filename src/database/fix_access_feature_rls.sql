-- Enable RLS and create policies for Access Control and Feature Management tables
-- Also includes dependencies like profiles and projects

-- 1. access_roles
ALTER TABLE public.access_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.access_roles;
CREATE POLICY "Enable read access for authenticated users" ON public.access_roles
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.access_roles;
CREATE POLICY "Enable insert access for authenticated users" ON public.access_roles
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.access_roles;
CREATE POLICY "Enable update access for authenticated users" ON public.access_roles
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.access_roles;
CREATE POLICY "Enable delete access for authenticated users" ON public.access_roles
    FOR DELETE TO authenticated USING (true);

-- 2. access_permissions
ALTER TABLE public.access_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.access_permissions;
CREATE POLICY "Enable read access for authenticated users" ON public.access_permissions
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.access_permissions;
CREATE POLICY "Enable insert access for authenticated users" ON public.access_permissions
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.access_permissions;
CREATE POLICY "Enable update access for authenticated users" ON public.access_permissions
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.access_permissions;
CREATE POLICY "Enable delete access for authenticated users" ON public.access_permissions
    FOR DELETE TO authenticated USING (true);

-- 3. app_components
ALTER TABLE public.app_components ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.app_components;
CREATE POLICY "Enable read access for authenticated users" ON public.app_components
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.app_components;
CREATE POLICY "Enable insert access for authenticated users" ON public.app_components
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.app_components;
CREATE POLICY "Enable update access for authenticated users" ON public.app_components
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.app_components;
CREATE POLICY "Enable delete access for authenticated users" ON public.app_components
    FOR DELETE TO authenticated USING (true);

-- 4. feature_requests
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.feature_requests;
CREATE POLICY "Enable read access for authenticated users" ON public.feature_requests
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.feature_requests;
CREATE POLICY "Enable insert access for authenticated users" ON public.feature_requests
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.feature_requests;
CREATE POLICY "Enable update access for authenticated users" ON public.feature_requests
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.feature_requests;
CREATE POLICY "Enable delete access for authenticated users" ON public.feature_requests
    FOR DELETE TO authenticated USING (true);

-- 5. feature_backlog
ALTER TABLE public.feature_backlog ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.feature_backlog;
CREATE POLICY "Enable read access for authenticated users" ON public.feature_backlog
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.feature_backlog;
CREATE POLICY "Enable insert access for authenticated users" ON public.feature_backlog
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.feature_backlog;
CREATE POLICY "Enable update access for authenticated users" ON public.feature_backlog
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.feature_backlog;
CREATE POLICY "Enable delete access for authenticated users" ON public.feature_backlog
    FOR DELETE TO authenticated USING (true);

-- 6. discussion_forum
ALTER TABLE public.discussion_forum ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.discussion_forum;
CREATE POLICY "Enable read access for authenticated users" ON public.discussion_forum
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.discussion_forum;
CREATE POLICY "Enable insert access for authenticated users" ON public.discussion_forum
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.discussion_forum;
CREATE POLICY "Enable update access for authenticated users" ON public.discussion_forum
    FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.discussion_forum;
CREATE POLICY "Enable delete access for authenticated users" ON public.discussion_forum
    FOR DELETE TO authenticated USING (true);

-- 7. profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.profiles;
CREATE POLICY "Enable read access for authenticated users" ON public.profiles
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable update access for users based on id" ON public.profiles;
CREATE POLICY "Enable update access for users based on id" ON public.profiles
    FOR UPDATE TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.profiles;
CREATE POLICY "Enable insert access for authenticated users" ON public.profiles
    FOR INSERT TO authenticated WITH CHECK (true);

-- 8. projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.projects;
CREATE POLICY "Enable read access for authenticated users" ON public.projects
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.projects;
CREATE POLICY "Enable all access for authenticated users" ON public.projects
    FOR ALL TO authenticated USING (true);

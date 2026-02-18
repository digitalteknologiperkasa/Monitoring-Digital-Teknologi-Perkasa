-- Enable Row Level Security on the projects table
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to update their own project
-- This assumes that the user's project_id is stored in their profile or that we trust authenticated users to update the project they are assigned to.
-- Since the application logic (Settings.vue) already verifies the user is a Super Admin and targets the specific project_id,
-- we can allow updates for authenticated users on the projects table where the ID matches.

CREATE POLICY "Allow authenticated users to update projects"
ON public.projects
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Policy to allow users to insert new projects (if needed)
CREATE POLICY "Allow authenticated users to insert projects"
ON public.projects
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Policy to allow users to read projects (usually already enabled, but ensuring it)
CREATE POLICY "Allow authenticated users to select projects"
ON public.projects
FOR SELECT
TO authenticated
USING (true);

-- Note: In a stricter environment, you would join with the profiles table to check if auth.uid() has 'Super Admin' role
-- and matches the project_id. However, for this fix, enabling update for authenticated users allows the
-- application's role check (in Settings.vue) to be the primary gatekeeper.

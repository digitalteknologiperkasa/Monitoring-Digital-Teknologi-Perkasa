-- Enable Row Level Security on version_logs table
ALTER TABLE public.version_logs ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to select version logs for their project
CREATE POLICY "Users can view version logs of their project"
ON public.version_logs
FOR SELECT
USING (
  project_id IN (
    SELECT project_id FROM public.profiles WHERE id = auth.uid()
  )
);

-- Policy to allow users to insert version logs for their project
CREATE POLICY "Users can insert version logs to their project"
ON public.version_logs
FOR INSERT
WITH CHECK (
  project_id IN (
    SELECT project_id FROM public.profiles WHERE id = auth.uid()
  )
);

-- Policy to allow users to update version logs for their project
CREATE POLICY "Users can update version logs of their project"
ON public.version_logs
FOR UPDATE
USING (
  project_id IN (
    SELECT project_id FROM public.profiles WHERE id = auth.uid()
  )
);

-- Policy to allow users to delete version logs for their project
CREATE POLICY "Users can delete version logs of their project"
ON public.version_logs
FOR DELETE
USING (
  project_id IN (
    SELECT project_id FROM public.profiles WHERE id = auth.uid()
  )
);

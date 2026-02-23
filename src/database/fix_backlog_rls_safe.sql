-- FIX: Safe RLS Policy Reset for Feature Backlog (IDEMPOTENT)
-- Run this in Supabase SQL Editor to fix permissions for backlog without errors

-- 1. Create table if not exists (Safe check)
CREATE TABLE IF NOT EXISTS public.feature_backlog ( 
   id bigint generated always as identity not null, 
   project_id bigint null, 
   feature_name text not null, 
   functionality text null, 
   urgency public.feature_urgency null default 'Medium'::feature_urgency, 
   placement_area text null, 
   dependencies text null, 
   impact_score integer null, 
   target_launch date null, 
   stage public.feature_stage null default 'Backlog'::feature_stage, 
   prd_link text null, 
   discussion_reference text null, 
   owner_id uuid null, 
   created_at timestamp with time zone null default now(), 
   updated_at timestamp with time zone null default now(), 
   constraint feature_backlog_pkey primary key (id), 
   constraint feature_backlog_owner_id_fkey foreign KEY (owner_id) references profiles (id) on delete set null, 
   constraint feature_backlog_project_id_fkey foreign KEY (project_id) references projects (id) on delete set null, 
   constraint feature_backlog_impact_score_check check ( 
     ( 
       (impact_score >= 1) 
       and (impact_score <= 10) 
     ) 
   ) 
 ) TABLESPACE pg_default;

-- 2. feature_backlog RLS: Reset total (Izinkan SEMUA akses untuk user login)
ALTER TABLE public.feature_backlog ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.feature_backlog;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.feature_backlog;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.feature_backlog;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.feature_backlog;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.feature_backlog;

CREATE POLICY "Enable all access for authenticated users" ON public.feature_backlog
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

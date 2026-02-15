-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.access_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  role_id uuid,
  component_id uuid,
  can_create boolean DEFAULT false,
  can_read boolean DEFAULT true,
  can_update boolean DEFAULT false,
  can_delete boolean DEFAULT false,
  can_verify boolean DEFAULT false,
  access_note text,
  updated_at timestamp with time zone DEFAULT now(),
  updated_by uuid,
  CONSTRAINT access_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT access_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.access_roles(id),
  CONSTRAINT access_permissions_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.app_components(id),
  CONSTRAINT access_permissions_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.access_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  project_id bigint,
  role_code character varying NOT NULL UNIQUE,
  role_name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT access_roles_pkey PRIMARY KEY (id),
  CONSTRAINT access_roles_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id)
);
CREATE TABLE public.app_components (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  project_id bigint,
  name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT app_components_pkey PRIMARY KEY (id),
  CONSTRAINT app_components_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id)
);
CREATE TABLE public.discussion_forum (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  parent_id bigint,
  parent_type text,
  user_id uuid NOT NULL,
  comment_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  attachment_url text,
  CONSTRAINT discussion_forum_pkey PRIMARY KEY (id),
  CONSTRAINT discussion_forum_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE INDEX IF NOT EXISTS idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);
CREATE TABLE public.feature_backlog (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  project_id bigint,
  feature_name text NOT NULL,
  functionality text,
  urgency USER-DEFINED DEFAULT 'Medium'::feature_urgency,
  placement_area text,
  dependencies text,
  impact_score integer CHECK (impact_score >= 1 AND impact_score <= 10),
  target_launch date,
  stage USER-DEFINED DEFAULT 'Backlog'::feature_stage,
  prd_link text,
  discussion_reference text,
  owner_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT feature_backlog_pkey PRIMARY KEY (id),
  CONSTRAINT feature_backlog_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id),
  CONSTRAINT feature_backlog_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.feature_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  project_id bigint,
  reporter_id uuid,
  component_id uuid,
  tanggal_pengajuan date DEFAULT CURRENT_DATE,
  status_perwakilan text CHECK (status_perwakilan = ANY (ARRAY['Inisiatif Sendiri'::text, 'Mewakili Pesantren'::text])),
  kode_pesantren text,
  unit_yayasan text,
  kategori_modul text,
  judul_request text NOT NULL,
  kategori_dev USER-DEFINED NOT NULL,
  deskripsi_masukan text,
  masalah text,
  usulan text,
  dampak text,
  urgensi USER-DEFINED DEFAULT 'Medium'::feature_urgency,
  attachment_wa text,
  attachment_lain text,
  status_lifecycle USER-DEFINED DEFAULT 'Baru'::request_lifecycle,
  alasan_penolakan text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT feature_requests_pkey PRIMARY KEY (id),
  CONSTRAINT feature_requests_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id),
  CONSTRAINT feature_requests_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id),
  CONSTRAINT feature_requests_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.app_components(id)
);
CREATE TABLE public.logs (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  project_id bigint NOT NULL,
  no_lap integer NOT NULL,
  version text NOT NULL,
  found_date timestamp with time zone NOT NULL,
  module text NOT NULL,
  priority USER-DEFINED NOT NULL DEFAULT 'medium'::log_priority,
  status USER-DEFINED NOT NULL DEFAULT 'report'::log_status,
  reporter_id uuid,
  actual_behavior text NOT NULL,
  expected_behavior text NOT NULL,
  severity_details text NOT NULL,
  attachment_link text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT logs_pkey PRIMARY KEY (id),
  CONSTRAINT logs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id),
  CONSTRAINT logs_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text,
  email text UNIQUE,
  role text DEFAULT 'Viewer'::text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  description text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.projects (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT projects_pkey PRIMARY KEY (id)
);
CREATE TABLE public.version_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  project_id bigint,
  component_id uuid,
  version_number text NOT NULL,
  release_date date DEFAULT CURRENT_DATE,
  change_type character varying DEFAULT 'Feature'::character varying,
  title text NOT NULL,
  details text,
  discussion_reference text,
  is_published boolean DEFAULT true,
  pic_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT version_logs_pkey PRIMARY KEY (id),
  CONSTRAINT version_logs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id),
  CONSTRAINT version_logs_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.app_components(id),
  CONSTRAINT version_logs_pic_id_fkey FOREIGN KEY (pic_id) REFERENCES public.profiles(id)
);
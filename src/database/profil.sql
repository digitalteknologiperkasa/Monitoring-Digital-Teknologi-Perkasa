-- Create Enum for User Roles
CREATE TYPE public.user_role AS ENUM ('Super Admin', 'Editor', 'Viewer');

-- Table: public.profiles
create table public.profiles (
  id uuid not null,
  full_name text null,
  email text null,
  role public.user_role null default 'Viewer'::public.user_role,
  avatar_url text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  description text null,
  project_id bigint null default 1,
  constraint profiles_pkey primary key (id),
  constraint profiles_email_key unique (email),
  constraint profiles_project_id_fkey foreign key (project_id) references public.projects(id)
) TABLESPACE pg_default;

-- Trigger for updated_at
create trigger update_profiles_modtime BEFORE
update on profiles for EACH row
execute FUNCTION update_updated_at_column ();

-- Initial Data
INSERT INTO "public"."profiles" ("id", "full_name", "email", "role", "avatar_url", "created_at", "updated_at", "description", "project_id") VALUES 
('03124ec6-6152-4863-bbc5-462e51122aff', null, 'digitek@psd.com', 'Viewer', null, '2026-02-12 06:18:15.124383+00', '2026-02-12 06:18:15.124383+00', null, 1), 
('7b87da68-5dcb-47a7-b998-a55b24f5ea8c', 'Super Admin', 'admin@digitek.com', 'Super Admin', 'https://robohash.org/rudi?set=set1', '2026-02-10 15:30:33.193821+00', '2026-02-10 18:06:04.931742+00', null, 1), 
('b1ffcd22-2d1c-5ff9-cc7e-7cc0ce491b22', 'Rudi', 'rudi@digitek.com', 'Editor', 'https://robohash.org/rudi?set=set4', '2026-02-10 04:49:58.102166+00', '2026-02-10 16:43:33.527372+00', '', 1), 
('cbcdb6e7-1446-4eed-990e-782f749235dc', 'Ganjar', 'ganjarpranowo@pdi.com', 'Super Admin', 'https://robohash.org/rudi?set=set2', '2026-02-10 16:01:16.124115+00', '2026-02-12 18:00:33.259644+00', '', 1), 
('ea25a450-174f-41e3-befe-af48c70a484e', 'Abdul', 'abdul@digitek.com', 'Viewer', 'https://robohash.org/rudi?set=set5', '2026-02-10 15:40:35.051228+00', '2026-02-10 16:39:08.497258+00', null, 1);

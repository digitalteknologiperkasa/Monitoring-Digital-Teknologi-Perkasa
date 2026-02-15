DROP TABLE IF EXISTS public.version_logs CASCADE;

create table public.version_logs (
  id uuid not null default gen_random_uuid (),
  project_id bigint null,
  component_id uuid null,
  version_number text not null,
  release_date text null, -- Changed from date to text to support "Menunggu PM"
  change_type character varying(50) null default 'Feature'::character varying,
  title text not null,
  details text null,
  status text null default 'Pending QA', -- New column
  notes text null, -- New column
  pic_name text null, -- New column for names like "Adi"
  discussion_reference text null,
  is_published boolean null default true,
  pic_id uuid null,
  created_at timestamp with time zone null default now(),
  constraint version_logs_pkey primary key (id),
  constraint version_logs_component_id_fkey foreign KEY (component_id) references app_components (id) on delete set null,
  constraint version_logs_pic_id_fkey foreign KEY (pic_id) references profiles (id) on delete set null,
  constraint version_logs_project_id_fkey foreign KEY (project_id) references projects (id) on delete CASCADE
) TABLESPACE pg_default;

-- Query untuk membersihkan data lama dan mengisi data dummy baru sesuai gambar
DELETE FROM public.version_logs;

-- Insert data dummy baru (Contoh dari gambar)
-- Catatan: project_id disesuaikan (misal 1), component_id disesuaikan jika ada.
INSERT INTO public.version_logs (
  version_number, 
  release_date, 
  pic_name, 
  change_type, 
  title, 
  details, 
  status, 
  notes, 
  project_id
) VALUES 
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Mengganti foto yang tampil pada sidebar', 'Unggah foto dan crop persegi', 'Pending QA', '-', 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Monitoring pengajar belum absen di beranda', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Daftar Monitoring Pengajar Belum Absen Hari Ini', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Rekapitulasi Presensi Pengajar (rekap tidak masuk)', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'Improvement', 'Riwayat Absensi Pengajar', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Rekap Pengajar Pengganti', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Riwayat Presensi Pengajar dan Pengganti', 'Penambahan endpoint dan index database', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Template Surat (Generate dari sample docx)', 'Penggunaan OpenTBS, table +surat_generated, +surat_logs', 'Pending QA', 'ada table surat_generate sep', 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Agenda Surat Masuk dan Keluar', 'table +klasifikasi_surat, +surat_agenda_counter', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'Bug Fix', 'Menampilkan riwayat absensi mengajar yang sesuai', 'Perbaikan dan penyesuain dialog modal riwayat', 'Pending QA', 'sebelumnya memanggil mod', 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Dashboard Jurnal, catatan penting dan todo list', 'slim +routes_admin_jurnalku.php, table +jurnalku_entries', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Pencatatan Jurnal Harian', NULL, 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Pencatatan Tugas / Todo List', NULL, 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Pembuatan Note / Catatan Singkat', NULL, 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Menampilkan profil user, login terakhir, IP, dll', 'Penambahan endpoint', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Ubah kata sandi sendiri', 'Penambahan endpoint', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Pengingat Kegiatan atau alarm sederhana', 'slim +routes_admin_pengingat.php, table +pengingat', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Tag/ Labeling Santri', 'slim +routes_santri_profil.php, table +santri_tag', 'Pending QA', NULL, 1),
('1.1.2', 'Menunggu PM', 'Adi', 'New Feature', 'Pencarian santri berdasar tag/ label', 'slim ubah routes_basisdata.php', 'Pending QA', NULL, 1);

create index IF not exists idx_version_logs_project_id on public.version_logs using btree (project_id) TABLESPACE pg_default;

create index IF not exists idx_version_logs_component_id on public.version_logs using btree (component_id) TABLESPACE pg_default;

create index IF not exists idx_version_logs_pic_id on public.version_logs using btree (pic_id) TABLESPACE pg_default;

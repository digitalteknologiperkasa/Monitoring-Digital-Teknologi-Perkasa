-- ==========================================
-- CLEANUP: Drop existing tables and types
-- ==========================================
DROP TABLE IF EXISTS public.feature_backlog CASCADE;
DROP TABLE IF EXISTS public.feature_requests CASCADE;

-- Drop types if they exist to avoid "already exists" errors
DROP TYPE IF EXISTS public.request_category CASCADE;
DROP TYPE IF EXISTS public.feature_urgency CASCADE;
DROP TYPE IF EXISTS public.request_lifecycle CASCADE;
DROP TYPE IF EXISTS public.feature_stage CASCADE;

-- ==========================================
-- 1. CREATE TYPES (ENUMS)
-- ==========================================
CREATE TYPE public.request_category AS ENUM (
    'Fitur Baru', 
    'Peningkatan Fitur', 
    'Optimasi Sistem', 
    'UI/UX', 
    'Keamanan'
);

CREATE TYPE public.feature_urgency AS ENUM (
    'Low', 
    'Medium', 
    'High', 
    'Critical'
);

CREATE TYPE public.request_lifecycle AS ENUM (
    'Baru', 
    'Sedang Ditinjau', 
    'Sedang Dipertimbangkan',
    'Sedang Dikembangkan', 
    'Ditolak', 
    'Selesai'
);

CREATE TYPE public.feature_stage AS ENUM (
    'Backlog', 
    'Discovery', 
    'Development', 
    'Testing', 
    'Launched'
);

-- ==========================================
-- 2. CREATE TABLES
-- ==========================================
CREATE TABLE public.feature_requests (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint REFERENCES public.projects(id) ON DELETE SET NULL,
    reporter_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    component_id uuid REFERENCES public.app_components(id) ON DELETE SET NULL,
    tanggal_pengajuan date DEFAULT CURRENT_DATE,
    status_perwakilan text CHECK (status_perwakilan IN ('Inisiatif Sendiri', 'Mewakili Pesantren')),
    kode_pesantren text,
    unit_yayasan text,
    kategori_modul text,
    judul_request text NOT NULL,
    kategori_dev public.request_category NOT NULL,
    deskripsi_masukan text,
    masalah text,
    usulan text,
    dampak text,
    urgensi public.feature_urgency DEFAULT 'Medium',
    attachment_wa text,
    attachment_lain text,
    status_lifecycle public.request_lifecycle DEFAULT 'Baru',
    alasan_penolakan text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE public.feature_backlog (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id bigint REFERENCES public.projects(id) ON DELETE SET NULL,
    feature_name text NOT NULL,
    functionality text,
    urgency public.feature_urgency DEFAULT 'Medium',
    placement_area text,
    dependencies text,
    impact_score integer CHECK (impact_score >= 1 AND impact_score <= 10),
    target_launch date,
    stage public.feature_stage DEFAULT 'Backlog',
    prd_link text,
    discussion_reference text,
    owner_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- ==========================================
-- 3. INSERT DUMMY DATA (10 Diverse Feature Requests)
-- ==========================================

-- Data 1: Absensi QR (Critical)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, kode_pesantren, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Sistem Absensi QR Dinamis', 'Fitur Baru', 'Mewakili Pesantren', 'P001', 'Kesiswaan', 'Absensi', 
    'QR Code yang berubah setiap 30 detik.', 'Kecurangan titip absen.', 'Integrasi TOTP QR.', 'Akurasi kehadiran 100%.', 'Critical', 'Sedang Dikembangkan'
);

-- Data 2: Dark Mode (Low)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Tema Gelap Dashboard', 'UI/UX', 'Inisiatif Sendiri', 'IT Support', 'UX', 
    'Opsi dark mode untuk kenyamanan mata.', 'Silau saat penggunaan malam hari.', 'Tailwind dark mode support.', 'User experience meningkat.', 'Low', 'Baru'
);

-- Data 3: Audit Log (High)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Audit Trail Aktivitas Admin', 'Keamanan', 'Inisiatif Sendiri', 'IT Audit', 'Security', 
    'Mencatat setiap perubahan data master.', 'Perubahan data tidak terlacak.', 'Database triggers for logging.', 'Keamanan data terjamin.', 'High', 'Sedang Ditinjau'
);

-- Data 4: Topup E-Wallet (Medium)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, kode_pesantren, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Auto-Topup Saldo Kantin', 'Peningkatan Fitur', 'Mewakili Pesantren', 'P005', 'Unit Usaha', 'Fintech', 
    'Topup otomatis via Virtual Account.', 'Saldo sering habis mendadak.', 'Integrasi API Bank.', 'Kelancaran transaksi kantin.', 'Medium', 'Sedang Dipertimbangkan'
);

-- Data 5: Broadcast WA (High)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Notifikasi WhatsApp Broadcast', 'Fitur Baru', 'Inisiatif Sendiri', 'Sekretariat', 'Notifikasi', 
    'Kirim pengumuman via WA Gateway.', 'Email/Web sering tidak terbaca.', 'Integrasi Fonnte/Wavix.', 'Informasi cepat sampai.', 'High', 'Selesai'
);

-- Data 6: Optimasi Report (Medium)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Optimasi Laporan Tahunan', 'Optimasi Sistem', 'Inisiatif Sendiri', 'Keuangan', 'Reporting', 
    'Percepat loading report > 1000 data.', 'Timeout saat generate PDF.', 'Query optimization & caching.', 'Laporan instan.', 'Medium', 'Sedang Ditinjau'
);

-- Data 7: Redesign Login (Low)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Redesign Halaman Login', 'UI/UX', 'Inisiatif Sendiri', 'Media', 'Auth', 
    'Tampilan login lebih modern.', 'Desain saat ini terlihat kaku.', 'Update UI dengan Glassmorphism.', 'Branding lebih kuat.', 'Low', 'Baru'
);

-- Data 8: Perizinan Digital (High)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, kode_pesantren, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'E-Perizinan Santri', 'Fitur Baru', 'Mewakili Pesantren', 'P008', 'Keamanan', 'Perizinan', 
    'Izin keluar via aplikasi.', 'Surat kertas sering hilang.', 'Workflow approval digital.', 'Monitoring santri akurat.', 'High', 'Baru'
);

-- Data 9: Integrasi Zoom (Medium)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Widget Zoom Webinar', 'Peningkatan Fitur', 'Inisiatif Sendiri', 'Akademik', 'E-Learning', 
    'Link zoom langsung di dashboard.', 'Link sering tercecer di WA.', 'Embed Zoom SDK/Link.', 'Belajar lebih fokus.', 'Medium', 'Ditolak'
);

-- Data 10: Multi-step Form (Medium)
INSERT INTO public.feature_requests (
    project_id, reporter_id, component_id, judul_request, kategori_dev, 
    status_perwakilan, unit_yayasan, kategori_modul, 
    deskripsi_masukan, masalah, usulan, dampak, urgensi, status_lifecycle
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    (SELECT id FROM public.profiles LIMIT 1), 
    (SELECT id FROM public.app_components LIMIT 1), 
    'Multi-step Form PSB', 'UI/UX', 'Inisiatif Sendiri', 'Humas', 'Admission', 
    'Pecah form pendaftaran jadi 3 tahap.', 'User drop-off karena form terlalu panjang.', 'Step-by-step UI.', 'Konversi pendaftar naik.', 'Medium', 'Baru'
);

-- ==========================================
-- 4. INSERT DUMMY BACKLOG (Linked to requests)
-- ==========================================

INSERT INTO public.feature_backlog (
    project_id, feature_name, functionality, urgency, placement_area, 
    impact_score, target_launch, stage, discussion_reference, owner_id
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    'Sistem Absensi QR Code Dinamis', 'TOTP Based QR Generation & Verification', 'High', 'Mobile App & Server', 
    9, CURRENT_DATE + INTERVAL '30 days', 'Development', '1', (SELECT id FROM public.profiles WHERE role = 'Super Admin' LIMIT 1)
);

INSERT INTO public.feature_backlog (
    project_id, feature_name, functionality, urgency, placement_area, 
    impact_score, target_launch, stage, discussion_reference, owner_id
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    'Rate Limiting API Publik', 'Redis based rate limiting for public endpoints', 'High', 'API Gateway', 
    8, CURRENT_DATE + INTERVAL '15 days', 'Development', '4', (SELECT id FROM public.profiles WHERE role = 'Super Admin' LIMIT 1)
);

INSERT INTO public.feature_backlog (
    project_id, feature_name, functionality, urgency, placement_area, 
    impact_score, target_launch, stage, discussion_reference, owner_id
) VALUES (
    (SELECT id FROM public.projects LIMIT 1), 
    'Audit Trail Perubahan Data Master', 'PostgreSQL Triggers for audit logging', 'Critical', 'Database Level', 
    10, CURRENT_DATE + INTERVAL '7 days', 'Discovery', '8', (SELECT id FROM public.profiles WHERE role = 'Super Admin' LIMIT 1)
);

-- ==========================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_backlog ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any to avoid duplicates
DROP POLICY IF EXISTS "Enable read access for all users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable update for owners and super admins" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable delete for super admins only" ON public.feature_requests;

DROP POLICY IF EXISTS "Enable read access for all users" ON public.feature_backlog;
DROP POLICY IF EXISTS "Enable all for super admins only" ON public.feature_backlog;

-- Policies for feature_requests
CREATE POLICY "Enable read access for all users" 
ON public.feature_requests FOR SELECT 
USING (true);

CREATE POLICY "Enable insert for authenticated users only" 
ON public.feature_requests FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for owners and super admins" 
ON public.feature_requests FOR UPDATE 
USING (
  auth.uid() = reporter_id OR 
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin')
);

CREATE POLICY "Enable delete for super admins only" 
ON public.feature_requests FOR DELETE 
USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin')
);

-- Policies for feature_backlog
CREATE POLICY "Enable read access for all users" 
ON public.feature_backlog FOR SELECT 
USING (true);

CREATE POLICY "Enable all for super admins only" 
ON public.feature_backlog FOR ALL 
USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin')
);


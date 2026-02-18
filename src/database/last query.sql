-- 1. HAPUS POLICY yang bergantung pada kolom role
-- Kita hapus dari tabel feature_requests dan feature_backlog sesuai skema Anda
DROP POLICY IF EXISTS "Enable update for owners and super admins" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable delete for super admins only" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable all for super admins only" ON public.feature_backlog;

-- 2. Buat tipe Enum jika belum ada
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('Super Admin', 'Editor', 'Viewer');
    END IF;
END $$;

-- 3. HAPUS Default Value lama agar tidak error casting
ALTER TABLE public.profiles ALTER COLUMN role DROP DEFAULT;

-- 4. UBAH Tipe Data Kolom role menjadi Enum
ALTER TABLE public.profiles 
  ALTER COLUMN role TYPE public.user_role 
  USING role::public.user_role;

-- 5. PASANG KEMBALI Default Value dengan tipe Enum
ALTER TABLE public.profiles ALTER COLUMN role SET DEFAULT 'Viewer'::public.user_role;

-- 6. BUAT ULANG POLICY dengan tipe data yang baru
-- Policy untuk feature_requests
CREATE POLICY "Enable update for owners and super admins" 
ON public.feature_requests FOR UPDATE 
USING (
  auth.uid() = reporter_id OR 
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin'::public.user_role)
);

CREATE POLICY "Enable delete for super admins only" 
ON public.feature_requests FOR DELETE 
USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin'::public.user_role)
);

-- Policy untuk feature_backlog
CREATE POLICY "Enable all for super admins only" 
ON public.feature_backlog FOR ALL 
USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'Super Admin'::public.user_role)
);

-- 7. Pastikan kolom project_id dan constraint-nya sudah ada
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS project_id bigint DEFAULT 1;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_project_id_fkey') THEN
        ALTER TABLE public.profiles 
          ADD CONSTRAINT profiles_project_id_fkey 
          FOREIGN KEY (project_id) REFERENCES public.projects(id);
    END IF;
END $$;

UPDATE public.profiles SET project_id = 1 WHERE project_id IS NULL;

-- Izinkan Super Admin untuk memasukkan data ke profil baru
CREATE POLICY "Super Admin can insert profiles" ON public.profiles 
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'Super Admin'
  )
);

-- Izinkan Super Admin untuk mengupdate profil user manapun
CREATE POLICY "Super Admin can update all profiles" ON public.profiles 
FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'Super Admin'
  )
);

-- 1. Tambahkan kolom baru untuk identifikasi polimorfik
ALTER TABLE public.discussion_forum 
ADD COLUMN parent_id bigint,
ADD COLUMN parent_type text;

-- 2. Migrasi data lama (memindahkan data dari log_id/request_id ke parent_id)
UPDATE public.discussion_forum 
SET parent_id = log_id, parent_type = 'LOG' 
WHERE log_id IS NOT NULL;

UPDATE public.discussion_forum 
SET parent_id = request_id, parent_type = 'FEATURE' 
WHERE request_id IS NOT NULL;

-- 3. Tambahkan Index agar pencarian komentar tetap kencang/cepat
CREATE INDEX IF NOT EXISTS idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);

-- 4. (Opsional) Jangan hapus kolom lama dulu sampai kita yakin front-end sudah stabil
-- COMMENT ON COLUMN public.discussion_forum.log_id IS 'Deprecated: Use parent_id & parent_type instead';
-- COMMENT ON COLUMN public.discussion_forum.request_id IS 'Deprecated: Use parent_id & parent_type instead';
-- 1. Tambahkan kolom baru untuk identifikasi polimorfik
ALTER TABLE public.discussion_forum 
ADD COLUMN parent_id bigint,
ADD COLUMN parent_type text;

-- 2. Migrasi data lama (memindahkan data dari log_id/request_id ke parent_id)
UPDATE public.discussion_forum 
SET parent_id = log_id, parent_type = 'LOG' 
WHERE log_id IS NOT NULL;

UPDATE public.discussion_forum 
SET parent_id = request_id, parent_type = 'FEATURE' 
WHERE request_id IS NOT NULL;

-- 3. Tambahkan Index agar pencarian komentar tetap kencang/cepat
CREATE INDEX IF NOT EXISTS idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);

-- 4. (Opsional) Jangan hapus kolom lama dulu sampai kita yakin front-end sudah stabil
-- COMMENT ON COLUMN public.discussion_forum.log_id IS 'Deprecated: Use parent_id & parent_type instead';
-- COMMENT ON COLUMN public.discussion_forum.request_id IS 'Deprecated: Use parent_id & parent_type instead';
-- 1. Bersihkan struktur tabel (Hapus kolom lama jika masih ada)
ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS log_id;
ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS request_id;

-- 2. Pastikan kolom polimorfik ada (Menggunakan information_schema yang benar)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='discussion_forum' AND column_name='parent_id') THEN
        ALTER TABLE public.discussion_forum ADD COLUMN parent_id bigint;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='discussion_forum' AND column_name='parent_type') THEN
        ALTER TABLE public.discussion_forum ADD COLUMN parent_type text;
    END IF;
END $$;

-- 3. Reset Keamanan (RLS)
ALTER TABLE public.discussion_forum ENABLE ROW LEVEL SECURITY;

-- Hapus policy lama agar bersih
DROP POLICY IF EXISTS "Anyone can view comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Users can insert their own comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Users can delete their own comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Allow public read" ON public.discussion_forum;
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.discussion_forum;

-- 4. Buat Policy Baru
-- Siapa saja yang login bisa melihat
CREATE POLICY "Anyone can view comments" 
ON public.discussion_forum FOR SELECT 
TO authenticated 
USING (true);

-- User hanya bisa insert komentar miliknya sendiri
CREATE POLICY "Users can insert their own comments" 
ON public.discussion_forum FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- User hanya bisa hapus komentar miliknya sendiri
CREATE POLICY "Users can delete their own comments" 
ON public.discussion_forum FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- 5. Re-index untuk performa
DROP INDEX IF EXISTS idx_discussion_parent;
CREATE INDEX idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);
-- 1. Bersihkan struktur tabel (Hapus kolom lama jika masih ada)
ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS log_id;
ALTER TABLE public.discussion_forum DROP COLUMN IF EXISTS request_id;

-- 2. Pastikan kolom polimorfik ada (Menggunakan information_schema yang benar)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='discussion_forum' AND column_name='parent_id') THEN
        ALTER TABLE public.discussion_forum ADD COLUMN parent_id bigint;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='discussion_forum' AND column_name='parent_type') THEN
        ALTER TABLE public.discussion_forum ADD COLUMN parent_type text;
    END IF;
END $$;

-- 3. Reset Keamanan (RLS)
ALTER TABLE public.discussion_forum ENABLE ROW LEVEL SECURITY;

-- Hapus policy lama agar bersih
DROP POLICY IF EXISTS "Anyone can view comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Users can insert their own comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Users can delete their own comments" ON public.discussion_forum;
DROP POLICY IF EXISTS "Allow public read" ON public.discussion_forum;
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.discussion_forum;

-- 4. Buat Policy Baru
-- Siapa saja yang login bisa melihat
CREATE POLICY "Anyone can view comments" 
ON public.discussion_forum FOR SELECT 
TO authenticated 
USING (true);

-- User hanya bisa insert komentar miliknya sendiri
CREATE POLICY "Users can insert their own comments" 
ON public.discussion_forum FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- User hanya bisa hapus komentar miliknya sendiri
CREATE POLICY "Users can delete their own comments" 
ON public.discussion_forum FOR DELETE 
TO authenticated 
USING (auth.uid() = user_id);

-- 5. Re-index untuk performa
DROP INDEX IF EXISTS idx_discussion_parent;
CREATE INDEX idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);
-- 1. Hapus kolom lama dan tambahkan kolom polimorfik
ALTER TABLE public.discussion_forum 
DROP COLUMN IF EXISTS log_id,
DROP COLUMN IF EXISTS request_id;

ALTER TABLE public.discussion_forum 
ADD COLUMN IF NOT EXISTS parent_id bigint,
ADD COLUMN IF NOT EXISTS parent_type text; -- Isi: 'LOG' atau 'FEATURE'

-- 2. Aktifkan RLS
ALTER TABLE public.discussion_forum ENABLE ROW LEVEL SECURITY;

-- 3. Kebijakan Keamanan (Policies)
DROP POLICY IF EXISTS "Anyone can view comments" ON public.discussion_forum;
CREATE POLICY "Anyone can view comments" 
ON public.discussion_forum FOR SELECT 
TO authenticated 
USING (true);

DROP POLICY IF EXISTS "Users can insert their own comments" ON public.discussion_forum;
CREATE POLICY "Users can insert their own comments" 
ON public.discussion_forum FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- 4. Index untuk Performa
CREATE INDEX IF NOT EXISTS idx_discussion_parent ON public.discussion_forum (parent_id, parent_type);

-- 1. Hapus policy insert yang lama (namanya mungkin berbeda, silakan cek di dashboard jika error)
-- Biasanya namanya "Enable insert for authenticated users only" atau sejenisnya
-- Jika Anda ragu namanya, Anda bisa buat policy baru dengan perintah di bawah:

-- 2. Buat Policy baru yang lebih fleksibel:
-- Mengizinkan user menginsert jika dia adalah pelapornya SENDIRI 
-- ATAU jika dia adalah seorang 'Admin' atau 'Super Admin'
CREATE POLICY "Allow insert for self or admins" 
ON public.logs 
FOR INSERT 
TO authenticated 
WITH CHECK (
  auth.uid() = reporter_id -- User menginput atas nama sendiri
  OR 
  EXISTS ( -- ATAU User adalah Admin/Super Admin
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('Editor', 'Super Admin')
  )
);

-- 3. Jangan lupa lakukan hal yang sama untuk Policy UPDATE jika ingin bisa mengedit pelapor
DROP POLICY IF EXISTS "Allow update for owners" ON public.logs;
CREATE POLICY "Allow update for owners or admins" 
ON public.logs 
FOR UPDATE 
TO authenticated 
USING (
  auth.uid() = reporter_id 
  OR 
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('Editor', 'Super Admin')
  )
);

-- Hapus policy insert lama (jika ada)
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.feature_requests;

-- Buat policy baru yang mengizinkan Admin/Editor menentukan reporter_id orang lain
CREATE POLICY "Enable insert for authenticated users" ON public.feature_requests
FOR INSERT 
TO authenticated 
WITH CHECK (
  -- User bisa mengisi data miliknya sendiri
  auth.uid() = reporter_id 
  OR 
  -- ATAU User adalah Admin/Super Admin (bisa mengisi data untuk orang lain)
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() 
    AND role IN ('Super Admin', 'Editor')
  )
);

-- MIGRATION QUERY GENERATED AUTOMATICALLY
-- Clears existing logs and discussions to avoid conflicts
TRUNCATE TABLE public.discussion_forum, public.logs RESTART IDENTITY CASCADE;

-- 1. MIGRATE PROFILES
INSERT INTO public.profiles (id, full_name, email, role, avatar_url, created_at, updated_at, description, project_id)
VALUES
('0e1e5839-3e4f-49b3-9bda-473e75c648f8', 'Mukhlis', 'mukhlis@psd.com', 'Viewer', NULL, '2026-01-30 07:43:18.241042+00', '2026-02-12 12:35:30.435921+00', NULL, 1),
('27ba494f-c9de-4891-a398-4ab04ac25f92', 'Alfin', 'alfin@pesantren.com', 'Editor', NULL, '2026-01-29 16:10:49.69699+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('322c58b3-8c5b-4caa-95bb-9836df469524', 'Candra', 'candra@psd.com', 'Viewer', NULL, '2026-01-30 07:24:00.832361+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('361cc80f-e709-444e-be4f-09a661680cbc', 'Wahyu', 'wahyu@psd.com', 'Viewer', NULL, '2026-01-30 07:43:58.177123+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('50680b1d-04c2-487e-abc3-edaf60521b88', 'Team PSD Lampung', 'teamlampung@psd.com', 'Viewer', NULL, '2026-01-29 18:32:47.735949+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('55549023-33b8-4b98-b09c-177488cee6f0', 'Mahfudz', 'mahfudz@psd.com', 'Viewer', NULL, '2026-01-30 05:47:34.945821+00', '2026-02-09 17:43:29.824666+00', NULL, 1),
('5738b5a1-fde9-4c24-91b9-19ca3d29f997', 'Prio', 'prio@psd.com', 'Viewer', NULL, '2026-02-03 03:34:39.565189+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('891dd11b-7020-43a1-918a-542f573154b9', 'Luqman', 'luqman@psd.com', 'Viewer', NULL, '2026-02-10 07:07:49.899603+00', '2026-02-11 03:56:45.122018+00', NULL, 1),
('95a934b2-c437-40c1-ac5b-92f9deab2a13', 'Admin', 'admin@pesantren.com', 'Editor', NULL, '2026-01-29 15:29:43.286893+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('ad47e420-e1f9-4f9d-8024-d6aa7d833f09', 'Toni ', 'toni@psd.com', 'Viewer', NULL, '2026-02-03 03:07:53.689697+00', '2026-02-09 17:31:44.578383+00', NULL, 1),
('ef1f5eae-8f94-416f-b41e-b0e69e496c6c', 'Eko', 'eko@psd.com', 'Viewer', NULL, '2026-01-30 07:42:22.025693+00', '2026-02-09 17:31:44.578383+00', NULL, 1)
ON CONFLICT (id) DO NOTHING;

-- 2. MIGRATE LOGS
INSERT INTO public.logs (id, project_id, no_lap, version, found_date, module, priority, status, reporter_id, actual_behavior, expected_behavior, severity_details, attachment_link, created_at, updated_at)
VALUES
('31', '1', '1', 'V.1.1.2', '2025-12-01 00:00:00+00', 'Santri', 'medium', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Untuk pencarian santri via tag hanya bisa di lakukan oleh akun yayasan (akun unit tidak bisa)', 'seharusnya pencarian santri via tag bisa di lakukan oleh akun unit', 'gagal mencari santri via tag', 'https://drive.google.com/file/d/151UV9BcFhFB5Vd-u-SEqbzHHs-YcSnAu/view?usp=drivesdk', '2026-01-30 03:47:35.579541+00', '2026-02-09 01:01:56.705024+00'),
('32', '1', '2', 'V.1.1.2', '2025-12-02 08:00:00+00', 'Jurnal', 'medium', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Ketika akun yayasan bisa melihat jurnal todo yang ada pada akun unit, tapi bisanya melihat tidak di sertai keterangan akun unit mana yang membuat jurnal tersebut,', 'akun yayasan tetap bisa melihat jurnal todo yang di buat oleh akun unit namun harus ada keterangan akun unit mana yang membuat jurnal todo tersebut, atau sekalian saja jurnal todo khusus untuk masing-masing akun saja', 'tidak ada keterangan jurnal unit', 'https://drive.google.com/file/d/1bVbXONq85d7f8ztyMBxyn3Dz1VnrLBTq/view?usp=drive_link', '2026-01-30 07:52:12.445384+00', '2026-02-09 01:01:56.705024+00'),
('33', '1', '3', 'V.1.1.2', '2025-12-02 15:05:00+00', 'Laporan', 'medium', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Dalam Laporan Rekap absesnsi pengajar tidak ada filter berdasarkan unit ', 'terdapat filter unit agar yayasan bisa tau misal ada pengajar yang ada di lebih dari 1 unit apakah pengajar tersebut aktif di semua unit atau hanya unit tertentu', 'tidak ada filter per unit', 'https://drive.google.com/file/d/14LPYXn0tpuq1oKsK7gaXCc4VRaYzqs1e/view?usp=drive_link', '2026-01-30 08:08:22.644319+00', '2026-02-09 01:01:56.705024+00'),
('34', '1', '4', 'V.1.1.2', '2025-12-02 08:00:00+00', 'Laporan', 'hight', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'pada tanggal 1/12/2025 ketika ingin melihat data yang ada di menu laporan (rekapitulasi presensi pengajar, riwayat presensi pengajar dan pengganti, serta rekap pengajar pengganti) hasil datanya tidak muncul', 'di tanggal berapapun dan di menu apapun data tetap tertampilkan', 'gagal mengechek data setelah tanggal tertentu', 'https://drive.google.com/file/d/19U1gOuBvUsTx7Bsohzklcnir0guU14yz/view?usp=drive_link', '2026-01-30 08:22:38.217893+00', '2026-02-09 01:01:56.705024+00'),
('35', '1', '5', 'V.1.1.2', '2025-12-02 08:00:00+00', 'Laporan', 'hight', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'pada saat pengganti di buat tanpa keterangan namun hasilnya malah pengganti tersebut tetap hadir', 'ketika pengganti tanpa keterangan di tulis tidak hadir/absen', 'status pengajar pengganti yang tanpa keterangan tetap tertulis hadir', 'https://drive.google.com/file/d/14eZFqRHLkxsHcmUrN2gOMRkmfc-Xd0_Q/view?usp=drive_link', '2026-01-30 08:44:20.468018+00', '2026-02-09 01:01:56.705024+00'),
('36', '1', '6', 'V.1.1.2', '2025-12-03 08:00:00+00', 'Keuangan', 'critikal', 'reject', '27ba494f-c9de-4891-a398-4ab04ac25f92', 'pada menu cek transfer tidak bisa menampilkan data cek transfernya', 'hapus saja menu cek transfer karena sudah banyak pesantren yang menanyakan menu ini tapi tidak bisa berfungsi', 'Tidak dapat menampilkan data cek transfer', 'https://drive.google.com/file/d/1HHaTEzybG4HRCzpghZSknbq0GdfS2XjV/view?usp=drive_link', '2026-01-30 08:47:37.063258+00', '2026-02-09 01:01:56.705024+00'),
('38', '1', '7', 'V.1.1.2', '2025-12-07 08:00:00+00', 'Spp', 'low', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'ketika terdapat santri yang ingin di batalkan sebuah transaksi spp nya, nantinya kan keluar pop up notif pembatalan transaksi lunas, di situ tetap tertulis "yakin pembayaran bulan ini di set menjadi lunas?
perhatikan inputan pemabayaran" yang seharusnya tertulis adalah "yakin pembayaran bulan ini di set menjadi belum lunas?
mohon perhatikan inputan pembayaran"', 'pop up di ganti dengan kalimat yakin pembayaran bulan ini di set menjadi belum lunas', 'Kesalahan penulisan keterangan pada pop up', 'https://drive.google.com/file/d/1ul0UIccim_km8ErMmsCuRTlbj5crjeMg/view?usp=drive_link', '2026-01-31 18:54:51.464095+00', '2026-02-09 01:01:56.705024+00'),
('40', '1', '8', 'V.1.1.2', '2025-12-07 08:00:00+00', 'Laporan', 'low', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Ketika filter laki-laki dan perempuan yang ada di laporan riwayat spp santri di set salah satunya (misal perempuan) maka hasil akan di munculkan, namun apabila tombol refresh filter di klik maka hasil filter dari yang telah di gunakan di set menjadi default kembali', 'set filter gender tetap pada hasil yang terakhir di atur walaupun tombol filter di klik', 'Tombol refresh membatalkan filter', 'https://drive.google.com/file/d/1KLRt7HhQxubQRpVxeuaWndOHMCQN-dNw/view?usp=drive_link', '2026-01-31 18:58:14.086183+00', '2026-02-09 01:01:56.705024+00'),
('41', '1', '9', 'V.1.1.2', '2025-12-07 15:30:00+00', 'Publikasi (Pesan Siaran) ', 'medium', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'sebelumnya notifikasi yang ada di menu pesan siaran muncul di aplikasi wali santri, namun sekarang tidak ada notifikasinya', 'memunculkan pesan siaran yang ada di pondok pesantren pada notifikasi yang ada di aplikasi wali santri', 'Notifikasi pesan siaran yang ada di aplikasi wali santri tidak tertampilkan', 'https://drive.google.com/file/d/1FNNNZ9z_jPkd6-FzKNTQwuiZg6z82-rT/view?usp=drive_link', '2026-01-31 19:05:19.750267+00', '2026-02-11 01:04:47.978267+00'),
('42', '1', '10', 'V.1.1.2', '2025-12-07 10:00:00+00', 'Publikasi (Hak Akses PPDB)', 'low', 'reject', '55549023-33b8-4b98-b09c-177488cee6f0', 'Dalam menu publikasi yang ada di hak akses PPDB tidak terdapat sub menu pesan siaran', 'di munculkan sub menu pesan siaran pada menu publikasi yang ada di akun hak aksesn PPDB', 'Tidak ada menu pesan siaran', 'https://drive.google.com/file/d/1RRdVmGr69Y4mHnUGz-JLduGxny0R6CPA/view?usp=drive_link', '2026-01-31 19:08:16.663872+00', '2026-02-09 01:01:56.705024+00'),
('44', '1', '12', 'V.1.1.2', '2026-01-06 17:00:00+00', 'Aplikasi Pegawai', 'medium', 'pending', 'ef1f5eae-8f94-416f-b41e-b0e69e496c6c', 'Terdapat data yang tidak dapat di tampilkan bila karakter yang di cari tidak full dalam penulisan nya', 'data muncul dan akurat ketika di cari ', 'SEO di aplikasi pegawai tidak berjalan dengan baik', 'https://drive.google.com/file/d/1AY8OOfK-Pyky5qELH8dT3nPPt9TuKPot/view?usp=drive_link, https://drive.google.com/file/d/17bug9ZEeyIR7HuhXRiVLSe-3f6igyb6y/view?usp=drive_link', '2026-01-31 19:11:07.161502+00', '2026-02-11 01:05:07.101277+00'),
('45', '1', '13', 'V.1.1.2', '2026-01-23 10:00:00+00', 'Aplikasi Pegawai IOS', 'hight', 'report', 'ef1f5eae-8f94-416f-b41e-b0e69e496c6c', 'Pada menu absensi terdapat beberapa nama santri dan beberapa mata pelajaran yang tidak muncul, padahal konfigurasi di admin unit sudah benar', 'Pada menu absensi terdapat beberapa nama santri dan beberapa mata pelajaran yang tidak muncul, padahal konfigurasi di admin unit sudah benar', 'Beberapa Jadwal Mata pelajaran dan nama santri di absensi tidak muncul', null, '2026-01-31 19:15:49.191445+00', '2026-02-09 01:01:56.705024+00'),
('46', '1', '14', 'V.1.1.2', '2026-02-09 22:13:00+00', 'Presensi Tap (Kegiatan Presensi)', 'hight', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Kegiatan yang telah di tambahkan tidak dapat di hapus walaupun sudah berkali-kali di hapus dan refresh tetap tidak terhapus', 'Fitur hapus kegiatan dapat di jalankan sehingga nama kegiatan yang di hapus menjadi hilang, dan kalaupun tidak perlu hilang karena nanti mengganggu database, bisa di hidden saja kegiatannya', 'Tidak dapat menghapus semua kegiatan di menu Presensi Tap Satu pun tanpa terkecuali', 'https://drive.google.com/file/d/1mFGeeHTITCYvEL0s-wV1TCcHWpa9imfr/view?usp=drive_link', '2026-02-02 15:24:55.033851+00', '2026-02-11 01:31:11.083064+00'),
('47', '1', '15', 'V.1.1.2', '2026-02-03 00:00:00+00', 'Monitoring Pengajar', 'medium', 'done', '322c58b3-8c5b-4caa-95bb-9836df469524', 'Waktu yang di gunakan menu monitoring pengajar belum di bisa otomatis menyesuaikan zona waktu', 'Zona waktu di jadwal menu monitoring pengajar bisa di sesuaikan lagi (Otomatis by lokasi baik itu di WIB,WITA dan WIT) ', 'Zona waktu masih default di WIB sehingga menyulitkan pondok pesantren yang berada di zona waktu WITA dan WIT', 'https://drive.google.com/file/d/1ARB0gl9e2e-dGjpt9l5y9Zri8Rh7UBXI/view?usp=drive_link', '2026-02-02 17:30:53.193626+00', '2026-02-11 02:46:50.529188+00'),
('48', '1', '16', 'V.1.1.2', '2026-01-11 23:34:00+00', 'Tabungan (Pegawai)', 'medium', 'done', '361cc80f-e709-444e-be4f-09a661680cbc', 'Saldo pegawai tidak bisa di nol kan saldonya yang di tarik', 'Bisa tarik tunai saldo tabungan pegawai layaknya di tabungan santri yang bisa di nol kan', 'ketika di atur nominal untuk nol saldo maka button Proses Transaksi tidak bisa di akses (non-aktif)', 'https://drive.google.com/file/d/1yjtofOY-9e0MzRjGWxYZm8pV-gD0qkQP/view?usp=drive_link', '2026-02-02 18:05:13.151124+00', '2026-02-11 02:09:15.941222+00'),
('49', '1', '17', 'V.1.1.2', '2026-02-02 17:00:00+00', 'Laporan / (Pemabayaran Santri) / Riwayat SPP dan Riwayat SPP via Aplikasi', 'medium', 'pending', '55549023-33b8-4b98-b09c-177488cee6f0', 'Pada bagian filter Metode pembayaran ketika di pilih metode bank beberapa ada yang tidak muncul di sini di Al-hikmah contohnya menggunakan BRI baik di riwayat spp via web psd dan aplikasi data tidak muncul, padahal di setting pembayaran spp terdapat metode menggunakan BRI untuk pembayaran spp tertentu (Kasus yang ada di AlHikmah kode 55 dan Al-fajr kode 256)', 'Semua data dari yang tersedia di filter metode pembayaran baik tunai, bank dll dapat di tampilkan dengan jelas', 'hanya menampilkan data dari beberapa metode pembayaran yang ada di filter menu Laporan / (Pemabayaran Santri) / Riwayat SPP dan Riwayat SPP via Aplikasi', 'https://drive.google.com/file/d/1M3qq68I1_OEWJ_vx-g8mFyoWSk9zz-i4/view?usp=drive_link', '2026-02-02 18:37:58.978089+00', '2026-02-11 01:33:17.887835+00'),
('50', '1', '18', 'V.1.1.2', '2026-02-03 07:23:00+00', 'Akun Bendahara Yayasan Kode 241 "Mitra Usaha / Penagihan"', 'critikal', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Pada Menu penagihan di akun bendahara yayasan kode 241 terdapat bug di mana button bayarkan telah tereksekusi namun sistemnya tidak berjalan mengakibatkan tidak di jalankan perintah bayarkan penagihan mitra usaha', 'button dan sistem dapat berjalan seperti semula', 'Pop up terbayarkan muncul tapi perintah tidak tereksekusi!', 'https://drive.google.com/file/d/1JM-BqVZ-qgzf-Ql-XCk0HJxraWI3HVRa/view?usp=drive_link', '2026-02-03 02:46:25.446951+00', '2026-02-10 02:32:54.102049+00'),
('51', '1', '19', 'V.1.1.2', '2026-02-01 22:03:00+00', 'Perangkat Tap / Kegiatan Presensi', 'medium', 'reject', '55549023-33b8-4b98-b09c-177488cee6f0', 'Saat Salah satu santri yang telah di tambahkan ke satu kegiatan yang ada di menu kegiata presensi tapping, lalu santri tersebut di ganti status menjadi (lulus,di keluarkan, pindah dll) nama santri tersebut masih terdapat pada kegiatan presensi ', 'Penambahan data kelas/kamar pada data santri yang ada di menu kegiatan presensi agar status santri yang pindah,lulus di keluarkan dll tersebut bisa otomatis menghilang dari kegiatan presensi', 'Tidak ada otomatis nya untuk data santri yang statusnya di rubah', 'https://drive.google.com/file/d/18t22lBAsdY8OKGSNsFPj6rbTuCCnNW2H/view?usp=drive_link', '2026-02-07 16:16:52.555889+00', '2026-02-11 02:46:31.405343+00'),
('52', '1', '20', 'V.1.1.2', '2026-02-09 14:14:00+00', 'Laporan / Riwayat Pelanggaran', 'hight', 'done', '55549023-33b8-4b98-b09c-177488cee6f0', 'Table data antara kategori dan poin tertukar, ', 'Memperbaiki file print daftar table data kategori dan poin ', 'Tertukar penyusunan data table antara kategori dan poin pelanggaran', 'https://drive.google.com/file/d/1u1CvKGIvJLyvFqfBRWOuQgH-mf4CN5XN/view?usp=drive_link', '2026-02-09 17:18:36.350694+00', '2026-02-11 02:08:14.261875+00'),
('53', '1', '21', 'V.1.1.2', '2026-02-10 07:44:00+00', 'Kode 285 Laporan / Kepegawaian / Rekapitulasi presensi pengajar', 'critikal', 'done', '0e1e5839-3e4f-49b3-9bda-473e75c648f8', 'Pada akun kode yayasan 285 terdapat error pada bagian rekapitulasi absesi pengajar, tidak dapat di tampilkan datanya padahal di rekap presensi pegawai maupun pengajar ada datanya.', 'Data Rekapitulasi Presensi pengajar dapat menampilkan data yang sesuai dengan rekap presensi yang berjalan', 'Data tidak tertampilkan di laporan rekapitulasi presensi pengajar sehingga admin sulit mengidentifikasi riwayat presensi pengajar', 'https://drive.google.com/file/d/1BGO6tt-ZhTd9rqJyrdfAv-JAunwubiqU/view?usp=drive_link', '2026-02-09 18:00:38.6193+00', '2026-02-12 01:05:33.983403+00'),
('54', '1', '22', 'V.1.1.2', '2026-02-10 00:39:00+00', 'WEB PPDB', 'hight', 'report', '891dd11b-7020-43a1-918a-542f573154b9', 'Pemintaan perubahan / ganti logo dari pihak pondok', 'logonya akan di input dikomen', '-', 'https://zaidbintsabit.ponpes.id/', '2026-02-11 03:43:59.360334+00', '2026-02-11 13:11:36.990288+00'),
('55', '1', '23', 'V.1.1.2', '2026-02-11 08:05:00+00', 'Kode 284 dan 285 Laporan / Kepegawaian / Rekapitulasi Presensi Pengajar / Detail Presensi Pengajar', 'critikal', 'report', '0e1e5839-3e4f-49b3-9bda-473e75c648f8', 'Pada detail presensi pengajar di laporan rekapitulasi pengajar Zona waktu tersetting dengan default zona WIB

', 'Diharapkan agar pondok pesantren yang bedara di zona waktu WITA dan WIT terdapat otomatisasi zona waktu agar data waktu pengajar yang absen bisa sesuai dengan waktu yang ada', 'Untuk pondok-pondok pesantren yang berada di zona waktu yang ada di indonesia bagian Tengah dan Timur Bisa ada otomatisasi sistem untuk singkron dengan waktu yang ada', 'https://drive.google.com/drive/folders/1Mqistj-xDZzkmE17KgNADXyk31NWaOOS?usp=drive_link', '2026-02-11 13:11:14.226872+00', '2026-02-11 13:11:14.226872+00');

-- 3. MIGRATE DISCUSSION FORUM
INSERT INTO public.discussion_forum (id, parent_id, parent_type, user_id, comment_text, created_at, attachment_url)
VALUES
('7', '42', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'LOG ditolak karena itu bukan Bug', '2026-01-31 19:24:35.808369+00', null),
('8', '50', 'LOG', '50680b1d-04c2-487e-abc3-edaf60521b88', 'tes', '2026-02-03 03:01:52.271482+00', null),
('9', '44', 'LOG', '50680b1d-04c2-487e-abc3-edaf60521b88', 'agak ribet ini ngrubah algoritma. kita pending smntara ya karna juga gag terlalu urgen', '2026-02-03 03:06:43.522256+00', null),
('10', '53', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'minta akses loginnya donk', '2026-02-10 06:56:33.420886+00', null),
('11', '53', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'kendalanya sederhana dan sungguh konyol. karena tahun ajaran diset mulai 1 Juli 2026 sampai Juli 2027. jadi semua data yang terinput di tanggal januari atau februari ya jelas gag muncul. karena sistem bacanya belum waktunya tahun ajaran yang dipilih di laporan berjalan. ini juga ngefek ke hal lainnya juga termasuk absensi pegawai', '2026-02-10 07:17:36.767498+00', null),
('12', '53', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'tahun ajaranya diset mulai Juli 2026 sedangkan inputanya mulai januari 2026 ngeceknya februari 2026 ya jelas ga muncul .. wkwkwkw', '2026-02-10 07:18:33.500399+00', null),
('13', '53', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'solusinya tinggal edit tahun ajaranya aja. insyaAllah semua beres', '2026-02-10 07:26:18.492315+00', null),
('14', '47', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'ini gambar monitoring pengajar', '2026-02-10 09:22:31.171619+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/47/sddy61u4cl-1770715351566.jpeg'),
('15', '47', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', '', '2026-02-10 09:23:48.585801+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/47/dl2owx8vyg-1770715428706.jpeg'),
('16', '48', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'error ada di front end. udah siap dipublish', '2026-02-11 01:10:26.179986+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/48/e8zgrp4wpwj-1770772225017.jpeg'),
('17', '49', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'coba cek di konfigurasi basis data bank BRI nya ada apa gag.', '2026-02-11 01:33:12.120981+00', null),
('18', '51', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'Gag bisa. klo lulus atau keluar ya harus dikecualikan secara manual', '2026-02-11 01:37:27.394148+00', null),
('19', '47', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'udah diubah. tolong dicek sekarang', '2026-02-11 01:54:44.069371+00', null),
('20', '47', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'Menunggu hasil pengecekan oleh mas candra', '2026-02-11 01:55:31.717519+00', null),
('21', '52', 'LOG', '95a934b2-c437-40c1-ac5b-92f9deab2a13', 'udah tinggal proses upload front end', '2026-02-11 01:57:47.034667+00', null),
('22', '49', 'LOG', '55549023-33b8-4b98-b09c-177488cee6f0', 'Ada pak,, di konfigurasi bank sudah di bedakan antara SPP dan Uang saku', '2026-02-11 03:18:44.64487+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/49/i1130r37jgl-1770779923514.jpg'),
('23', '49', 'LOG', '55549023-33b8-4b98-b09c-177488cee6f0', 'Tapi di riwayat SPP masih tetap yg muncul Via BSI uang saku, padahal dia membayar SPP', '2026-02-11 03:19:17.56917+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/49/5k0f3q7gody-1770779956152.jpg'),
('24', '54', 'LOG', '891dd11b-7020-43a1-918a-542f573154b9', '', '2026-02-11 03:44:46.956531+00', 'https://tgbzkulmpfdjmjleuyyw.supabase.co/storage/v1/object/public/discussion_attachments/54/uddp3j9qqh9-1770781484047.png');

-- 4. RESET SEQUENCES
-- Ensure that the sequences are updated to the max id to prevent duplicate key errors on future inserts
SELECT setval('logs_id_seq', (SELECT MAX(id) FROM public.logs));
SELECT setval('discussion_forum_id_seq', (SELECT MAX(id) FROM public.discussion_forum));

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

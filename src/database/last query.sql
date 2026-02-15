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
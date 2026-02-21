-- FIX: RPC Function for Robust Feature Request Submission
-- Run this in Supabase SQL Editor to create a server-side function that bypasses RLS

-- 1. Drop existing policies to ensure no conflicts
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON public.feature_requests;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON public.feature_requests;

-- 2. Re-create a simple permissive policy for direct access (optional but good for reading)
CREATE POLICY "Enable all access for authenticated users" ON public.feature_requests
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 3. Create the RPC function (SECURITY DEFINER bypasses RLS)
CREATE OR REPLACE FUNCTION public.submit_feature_request(
    p_project_id bigint,
    p_component_id uuid,
    p_reporter_id uuid,
    p_judul_request text,
    p_kategori_dev text,
    p_deskripsi_masukan text,
    p_urgensi text,
    p_status_perwakilan text,
    p_kode_pesantren text,
    p_unit_yayasan text,
    p_kategori_modul text,
    p_masalah text,
    p_usulan text,
    p_dampak text,
    p_attachment_wa text,
    p_attachment_lain text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with admin privileges
SET search_path = public
AS $$
DECLARE
    v_result jsonb;
    v_new_id bigint;
BEGIN
    INSERT INTO public.feature_requests (
        project_id,
        component_id,
        reporter_id,
        judul_request,
        kategori_dev,
        deskripsi_masukan,
        urgensi,
        status_perwakilan,
        kode_pesantren,
        unit_yayasan,
        kategori_modul,
        masalah,
        usulan,
        dampak,
        attachment_wa,
        attachment_lain,
        status_lifecycle,
        created_at,
        updated_at
    ) VALUES (
        p_project_id,
        p_component_id,
        p_reporter_id,
        p_judul_request,
        p_kategori_dev::public.request_category, -- Explicit cast
        p_deskripsi_masukan,
        p_urgensi::public.feature_urgency, -- Explicit cast
        p_status_perwakilan,
        p_kode_pesantren,
        p_unit_yayasan,
        p_kategori_modul,
        p_masalah,
        p_usulan,
        p_dampak,
        p_attachment_wa,
        p_attachment_lain,
        'Baru',
        now(),
        now()
    )
    RETURNING id INTO v_new_id;

    -- Return the inserted row as JSON
    SELECT to_jsonb(fr.*) INTO v_result FROM public.feature_requests fr WHERE id = v_new_id;
    
    RETURN v_result;
END;
$$;

-- 4. Grant execute permission
GRANT EXECUTE ON FUNCTION public.submit_feature_request TO authenticated;

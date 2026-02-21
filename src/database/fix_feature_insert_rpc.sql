-- Function to safely insert feature request bypassing RLS issues
-- Run this in Supabase SQL Editor

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
SECURITY DEFINER -- Runs with admin permissions
SET search_path = public
AS $$
DECLARE
    v_result jsonb;
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
        p_kategori_dev,
        p_deskripsi_masukan,
        p_urgensi,
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
    RETURNING to_jsonb(feature_requests.*) INTO v_result;

    RETURN v_result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.submit_feature_request TO authenticated;

-- SQL MANUAL INSERT UNTUK FEATURE REQUEST
-- Silakan copy dan jalankan di Supabase SQL Editor
-- Script ini akan memasukkan data sesuai screenshot Anda

INSERT INTO public.feature_requests (
    project_id,
    reporter_id,
    component_id,
    status_perwakilan,
    kode_pesantren,
    unit_yayasan,
    kategori_modul,
    judul_request,
    kategori_dev,
    deskripsi_masukan,
    masalah,
    usulan,
    dampak,
    urgensi,
    attachment_wa,
    attachment_lain,
    status_lifecycle
) VALUES (
    1, -- project_id (Pastikan project dengan ID 1 ada)
    '2a1881a3-2e8f-4fcf-bea3-979f7f51c86d', -- reporter_id
    '41ac6f02-2f1d-4702-9df3-767b22eacafd', -- component_id
    'Inisiatif Sendiri', -- status_perwakilan
    NULL, -- kode_pesantren (karena Inisiatif Sendiri)
    'tahfidz', -- unit_yayasan
    'akademik', -- kategori_modul
    'Penambahan Search bar dan riwayat pencarian surat', -- judul_request (Typo corrected)
    'Peningkatan Fitur', -- kategori_dev
    'Di saat ustadz ingin menambahkan catatan hafalan santri, mereka kesulitan mencari surat jika listnya panjang.', -- deskripsi_masukan
    'Kesulitan mencari nama surat yang sesuai', -- masalah
    'Tampilkan search bar', -- usulan
    'memperlambat pencatatan hafalan santri', -- dampak
    'High', -- urgensi
    'https://drive.google.com/file/d/19_u3UNTCgtmjmq9P90b9E...', -- attachment_wa (Link disingkat dari screenshot, silakan ganti jika perlu)
    NULL, -- attachment_lain
    'Baru' -- status_lifecycle
);

-- DEBUGGING JIKA MASIH GAGAL/HANG (Opsional)
-- Jalankan query di bawah ini untuk melihat apakah ada TRIGGER yang bikin lemot/error
/*
SELECT 
    event_object_schema as table_schema,
    event_object_table as table_name,
    trigger_name,
    event_manipulation as trigger_event,
    action_statement as trigger_action,
    action_timing as trigger_timing
FROM information_schema.triggers
WHERE event_object_table = 'feature_requests';
*/

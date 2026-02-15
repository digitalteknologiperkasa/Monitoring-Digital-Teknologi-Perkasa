create table public.projects (
  id bigint generated always as identity not null,
  name text not null,
  description text null,
  created_at timestamp with time zone null default now(),
  constraint projects_pkey primary key (id)
) TABLESPACE pg_default;

ini isi nya
INSERT INTO "public"."projects" ("id", "name", "description", "created_at") VALUES ('1', 'Pesantren Smart Digital', 'Portal utama untuk manajemen akademik siswa dan guru.', '2026-02-10 04:49:58.102166+00'), ('2', 'E-Learning Platform', 'Platform pembelajaran daring dan manajemen tugas.', '2026-02-10 04:49:58.102166+00'), ('3', 'Mobile App Wali Santri', 'Aplikasi mobile untuk orang tua memantau perkembangan santri.', '2026-02-10 04:49:58.102166+00'), ('4', 'Keuangan & Payroll System', 'Manajemen gaji guru dan pembayaran SPP.', '2026-02-10 04:49:58.102166+00'), ('5', 'Library Management System', 'Peminjaman dan pengembalian buku perpustakaan.', '2026-02-10 04:49:58.102166+00'), ('6', 'Attendance System (Face Rec)', 'Sistem absensi wajah untuk siswa dan staf.', '2026-02-10 04:49:58.102166+00'), ('7', 'Inventory Aset Sekolah', 'Tracking inventaris meja, kursi, komputer, dll.', '2026-02-10 04:49:58.102166+00'), ('8', 'Alumni Network Portal', 'Website untuk jejaring alumni sekolah.', '2026-02-10 04:49:58.102166+00'), ('9', 'PPDB Online System', 'Penerimaan Peserta Didik Baru secara online.', '2026-02-10 04:49:58.102166+00'), ('10', 'School Canteen POS', 'Point of Sales untuk kantin sekolah.', '2026-02-10 04:49:58.102166+00');
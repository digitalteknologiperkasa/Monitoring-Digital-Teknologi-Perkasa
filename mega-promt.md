# 🚀 MEGA PROMPT: Migrasi Monitoring Digitek ke Vue.js Framework

## 🎯 Objektif Utama
Migrasikan seluruh ekosistem aplikasi **Monitoring Digitek (Log Error, Bug, Access Control, & Version Control)** dari vanilla HTML/JS ke framework **Vue.js (Vite)**. Proyek ini harus mengintegrasikan berbagai desain terbaru dari folder `RAW` untuk menciptakan satu platform yang kohesif, responsif, dan modern.

---

## 🛠️ Stack Teknologi Target
- **Framework**: Vue 3 (Composition API) + Vite.
- **Styling**: Tailwind CSS.
- **Backend/Auth**: Supabase.
- **Icons**: Material Symbols & Lucide Icons.
- **Charts**: Chart.js atau Vue-ChartJS.

---

## 🗺️ Panduan Struktur & Komponen

### 1. 📂 Autentikasi & Konfigurasi
- **Sumber**: [index.html](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/index.html) & [supabase-config.js](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/supabase-config.js).
- **Instruksi**: Migrasikan logika login Supabase. Pastikan sistem dapat membedakan Role (Editor vs Viewer) sejak proses login untuk menentukan akses menu.

### 2. 📱 Sidebar & Navigasi (PENTING!)
- **Sumber**: [design menu access control.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/design%20menu%20access%20control.md) & [design menu version control.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/design%20menu%20version%20control.md).
- **Instruksi**: 
    - **JANGAN** gunakan desain navigasi dari file editor/viewer lama.
    - Gunakan desain terbaru yang mencakup **Header Icon Switch Light/Dark Mode** yang sudah diupdate.
    - Implementasikan **Avatar User** dengan **Icon Logout** yang telah dioptimalkan di bagian bawah sidebar.
    - Sidebar harus responsif dan mendukung transisi smooth.

### 3. 📊 Dashboard Utama
- **Sumber**: [redesign dashboard.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/redesign%20dashboard.md).
- **Instruksi**: Dashboard harus menampilkan ringkasan/kutipan data dari 4 menu utama:
    1. **Log Error & Bug**: Total logs, status pending/resolved.
    2. **Version Control**: Versi terbaru aplikasi.
    3. **Access Control**: Ringkasan jumlah user/role.
    4. **Report & Analytics**: Grafik mini tren mingguan.

- Lalu Pada bagian side nav bagian bawah terdapat menu manajemen akses tim yang berisi daftar user akses-akses yang telah ada di dalam sistem baik nama, email, role, dan status aktif atau tidak sesuai dengan yang ada di file editor access.html dan viewer access.html.
- baru di bagian paling bawah ada setting yang berisi opsi untuk mengubah mode light dan dark, dan beberapa fitur lainnya sesuai yang ada di file editor access.html dan viewer access.html.


### 4. 📈 Report & Analytics
- **Sumber**: [tambahan data laporan di menu report.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/tambahan%20data%20laporan%20di%20menu%20report.md).
- **Instruksi**: Implementasikan visualisasi data penuh menggunakan:
    - **Line Chart**: Tren Log Error harian/bulanan.
    - **Bar Chart**: Distribusi bug per platform (Android, iOS, Web).
    - **Donut/Pie Chart**: Persentase distribusi Role & Akses.
    - **Statistics Cards**: Angka-angka kunci performa sistem.

### 5. 🛠️ Menu Log Error & Bug
- **Sumber**: [editor access.html](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/editor%20access.html) & [viewer access.html](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/viewer%20access.html).
- **Instruksi**: Gunakan struktur tabel dan filter dari file ini. Pastikan fungsionalitas CRUD (Create, Read, Update, Delete) hanya aktif untuk user dengan role **Editor**.

### 6. 🔐 Access Control Matrix
- **Sumber**: [design menu access control.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/design%20menu%20access%20control.md).
- **Instruksi**: Implementasikan tabel matriks CRUDV (Create, Read, Update, Delete, Verify) yang menunjukkan hak akses setiap role terhadap modul aplikasi.

### 7. 🏷️ Version Control
- **Sumber**: [design menu version control.md](file:///d:/Vue/Monitoring%20Digitek%20(Log%20Error,Bug,Access%20Control%20and%20Version%20Control)/RAW/design%20menu%20version%20control.md).
- **Instruksi**: Implementasikan timeline atau tabel versi aplikasi yang mencakup nomor versi, tanggal rilis, dan kategori update (Feature, Bug Fix, Security).

---

## 💡 Catatan Tambahan (Dari Note.md)
- Utamakan penggunaan **Node.js/Vite** untuk performa terbaik.
- Pastikan sistem **Dark Mode** bekerja secara global di seluruh komponen.
- Gunakan komponen Vue yang *reusable* untuk elemen seperti Modal, Button, dan Input.

---
*Dokumen ini disusun sebagai panduan komprehensif untuk proses migrasi sistem Monitoring Digitek.*

Saya telah menyusun README.md baru di folder RAW yang menggabungkan seluruh instruksi migrasi menjadi sebuah "mega prompt" yang terperinci.

Ringkasan Perubahan:

- Sidebar/Navigasi : Mengarahkan untuk menggunakan desain terbaru dari access control & version control (termasuk switch dark mode dan icon logout baru).
- Dashboard : Menginstruksikan pembuatan dashboard yang menampilkan ringkasan dari 4 modul utama berdasarkan redesign dashboard.md .
- Reports : Menambahkan instruksi untuk visualisasi data (Line, Bar, Donut charts) berdasarkan tambahan data laporan di menu report.md .
- Konten Utama : Tetap menggunakan struktur dari file editor dan viewer untuk bagian Log Error.
- Teknologi : Menetapkan target migrasi ke Vue 3 + Vite + Tailwind CSS + Supabase.
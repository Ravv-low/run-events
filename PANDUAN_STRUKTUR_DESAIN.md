# 🏃 PANDUAN PETA FILE DESAIN & PENGGUNAAN LARAVEL (PaceNation)

Dokumen ini dibuat untuk memudahkan Anda (bahkan bagi pemula) saat ingin mengotak-atik tampilan/desain website **PaceNation**.

---

## 💡 1. Dimana Penggunaan Laravel-nya?

Website ini dibangun menggunakan **Framework Laravel 11** dengan arsitektur MVC (Model-View-Controller):

1. **Routing (`routes/web.php`)**:
   - Mengatur semua alamat URL (misal `/` ke halaman Login, `/home` ke Katalog Event, `/admin/dashboard` ke Admin).
2. **Controllers (`app/Http/Controllers/`)**:
   - Mengatur logika bisnis seperti proses login, menyimpan pendaftaran event, memproses diskon kupon, dan CRUD event admin.
3. **Models & Migrations (`app/Models/` & `database/migrations/`)**:
   - Mengelola struktur database dan tabel (`User`, `Event`, `Registration`, `Coupon`).
4. **Middleware (`app/Http/Middleware/AdminMiddleware.php`)**:
   - Keamanan / Pembatas Akses: Memastikan user biasa tidak bisa masuk ke halaman Admin.
5. **Blade Views (`resources/views/`)**:
   - Tampilan HTML + CSS (TailwindCSS) yang dilihat oleh pengguna di browser.

---

## 🎨 2. Peta File Tampilan (Blade Views) untuk Diotak-Atik

Semua tampilan visual website berada di folder `resources/views/`. Berikut petanya:

```text
resources/views/
├── layouts/
│   └── app.blade.php           <-- [UTAMA] Master Template (Navbar, Footer, Font, Script CSS)
│
├── auth/
│   ├── login.blade.php         <-- Halaman Form Login (Halaman awal website '/')
│   └── register.blade.php      <-- Halaman Form Pendaftaran Akun Runner Baru ('/register')
│
├── landing.blade.php           <-- Halaman Utama PaceNation (Katalog Event Lari untuk Peserta)
│
├── events/
│   └── show.blade.php          <-- Halaman Detail Event & Form Pendaftaran Tiket Lari
│
├── peserta/
│   └── dashboard.blade.php     <-- Dashboard Peserta (Tiket E-BIB & Status Pembayaran)
│
└── admin/                      <-- [KHUSUS ROLE ADMIN]
    ├── dashboard.blade.php     <-- Dashboard Admin (Statistik & Ringkasan Pendaftaran)
    └── events/
        ├── index.blade.php     <-- Tabel Daftar Event yang dikelola Admin
        ├── create.blade.php    <-- Form Tambah Event Baru
        └── edit.blade.php      <-- Form Edit Event
```

---

## 🖼️ 3. Lokasi Gambar & Poster Event

Gambar poster event tersimpan dengan rapi di:
📁 **`public/images/events/`**

Tersedia 3 gambar poster bawaan:
1. `jakarta-night-run.png` (Jakarta International 10K Night Run)
2. `bali-sunset-marathon.png` (Bali Sunset Half Marathon)
3. `borobudur-marathon.png` (Borobudur Heritage Full Marathon)

> **Tips Otak-Atik Gambar**:
> Jika Anda ingin menambah gambar poster secara manual tanpa upload via admin, cukup taruh file gambar di folder `public/images/events/` lalu panggil path-nya di database/seeder!

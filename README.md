<p align="center">
  <img src="https://ravv-low.github.io/run-events/public/images/events/banner-pacenation.png" alt="PaceNation Marathon Event Platform" width="100%">
</p>
# 🏃 PaceNation - Platform Maraton & Event Lari (Laravel 11)

**PaceNation** adalah platform manajemen maraton dan event lari modern berbasis **Laravel 11**. Platform ini dilengkapi dengan sistem autentikasi role-based, manajemen tiket E-BIB digital, kupon promo, dan **fitur pengelolaan slot kuota event otomatis**.

---

## 🌟 Fitur Utama & Keunggulan

1. **Sistem Slot Event Real-Time & Otomatis**:
   - Pemisahan data yang jelas antara **Kuota Total (`quota`)** dan **Jumlah Peserta Terdaftar (`registrations_count`)**.
   - **Kalkulasi Sisa Slot Otomatis**: System secara otomatis menghitung sisa slot (`remaining_slots = quota - registrations_count`).
   - **Proteksi Overbooking Penuh**: Pendaftaran akan ditolak secara otomatis oleh sistem jika slot kuota sudah penuh / Sold Out.
   - Pendaftaran menggunakan penguncian transaksi database (`DB::transaction` & `lockForUpdate`) untuk menjamin keamanan slot walau diakses bersamaan.

2. **Sistem Autentikasi & Pembatasan Role (Middleware)**:
   - **Role `admin`**: Diarahkan ke Dashboard Admin untuk mengelola event lari, mengatur kuota slot, dan memverifikasi pembayaran.
   - **Role `peserta` (Runner)**: Diarahkan ke Dashboard Peserta untuk melihat E-BIB digital resmi dan riwayat pendaftaran.
   - Halaman utama (`/`) langsung menampilkan katalog event lari & form pendaftaran.

3. **Tampilan Modern & Konsisten (TailwindCSS)**:
   - Desain sporty yang responsif dengan *glassmorphism*, indikator progress kuota, dan poster event resolusi tinggi di folder `public/images/events/`.

---

## 📂 Struktur Folder Proyek & View (Ramah Pemula)

Semua file tampilan disimpan terorganisir di dalam folder `resources/views/` sesuai dengan fungsinya:

```text
resources/views/
├── auth/                      <-- [AUTENTIKASI GUEST]
│   ├── login.blade.php        <-- Tampilan Form Login Pengguna / Admin
│   └── register.blade.php     <-- Tampilan Form Pendaftaran Akun Runner Baru
│
├── user/                      <-- [KATALOG EVENT USER]
│   ├── index.blade.php        <-- Katalog Event Lari publik & Indikator Sisa Slot
│   └── show.blade.php         <-- Detail Event & Form Pendaftaran Tiket Lari
│
├── peserta/                   <-- [DASHBOARD PESERTA]
│   └── dashboard.blade.php    <-- E-BIB Digital & Riwayat Pembayaran Runner
│
├── admin/                     <-- [DASHBOARD ADMIN]
│   ├── dashboard.blade.php    <-- Ringkasan Statistik, Pendapatan & Verifikasi Pembayaran
│   └── events/                <-- Management CRUD Event & Kuota Slot
│       ├── index.blade.php    <-- Tabel Daftar Event & Status Sisa Slot
│       ├── create.blade.php   <-- Form Tambah Event Lari Baru
│       └── edit.blade.php     <-- Form Edit Event & Kuota Slot
│
└── layouts/
    └── app.blade.php          <-- Master Template (Navbar, Header, Footer, CSS & Toast Notification)
```

### 🧠 Struktur Controllers (`app/Http/Controllers/`)
- `AuthController.php` ➔ Penanganan login, register, logout, dan pengalihan role.
- `HomeController.php` ➔ Penanganan katalog event publik & detail event untuk user.
- `RegistrationController.php` ➔ Penanganan transaksi pendaftaran tiket & potongan sisa slot.
- `ParticipantDashboardController.php` ➔ Penanganan E-BIB digital runner.
- `Admin/AdminDashboardController.php` ➔ Penanganan statistik & verifikasi status pembayaran admin.
- `Admin/AdminEventController.php` ➔ Penanganan CRUD event lari admin.

---

## ⚡ Fitur Pengaturan Slot Event (Detail Teknis)

### 1. Skema Tabel Database (`events`)
- `quota` *(integer)*: Jumlah batas maksimum peserta yang diizinkan mendaftar.
- `registrations_count` *(integer)*: Jumlah akumulasi peserta yang berhasil mendaftar (terbayar/paid).

### 2. Logika Model Event (`app/Models/Event.php`)
```php
// Accessor hitung sisa slot otomatis
public function getRemainingSlotsAttribute(): int
{
    return max(0, $this->quota - $this->registrations_count);
}

// Cek apakah slot sudah habis
public function isSoldOut(): bool
{
    return $this->remaining_slots <= 0;
}
```

### 3. Validasi & Auto-Deduction pada Transaksi Pendaftaran (`RegistrationController.php`)
```php
DB::transaction(function () use ($request, $user) {
    $event = Event::where('id', $request->event_id)->lockForUpdate()->firstOrFail();

    // Tolak pendaftaran jika slot penuh
    if ($event->registrations_count >= $event->quota || $event->isSoldOut()) {
        throw new \Exception("Maaf, slot pendaftaran event ini sudah penuh (Sold Out)!");
    }

    // Simpan pendaftaran baru...
    $registration = Registration::create([...]);

    // Otomatis tambah jumlah pendaftar
    $event->increment('registrations_count');

    return $registration;
});
```

---

## 🚀 Langkah Menjalankan Proyek di Lokal

1. **Jalankan Migration & Database Seeder**:
   ```bash
   php artisan migrate:fresh --seed
   ```
2. **Jalankan Server Lokal Laravel**:
   ```bash
   php artisan serve
   ```
3. **Buka Aplikasi di Browser**:  
   Akses `http://127.0.0.1:8000`

### 🔑 Akun Uji Coba Default:
- **Akun Admin**: `admin@pacenation.com` | Password: `password`
- **Akun Runner/Peserta**: `runner@pacenation.com` | Password: `password`

---
*Dikembangkan dengan Laravel 11 untuk platform PaceNation Marathon.*

# 🏃 PaceNation - Marathon & Running Event Platform (Laravel 11)

An end-to-end event management platform designed for marathon organizers and runners. Built with Laravel 11 and TailwindCSS, featuring real-time slot allocation, concurrency protection, and role-based access control.

---

## 🌟 Key Features & Highlights

1. **Real-Time & Automated Slot Management**:
   - Clear data separation between **Total Quota (`quota`)** and **Registered Participants (`registrations_count`)**.
   - **Automated Slot Calculation**: Computes remaining slots dynamically (`remaining_slots = quota - registrations_count`).
   - **Overbooking Protection**: Rejects registrations automatically once the quota is exhausted / Sold Out.
   - Utilizes database transactions (`DB::transaction` & `lockForUpdate`) to prevent race conditions during high-concurrency registrations.

2. **Authentication & Role-Based Middleware**:
   - **`admin` Role**: Access to the Admin Dashboard to manage running events, set quotas, and verify participant payments.
   - **`peserta` Role (Runner)**: Access to the Runner Dashboard to view official digital E-BIBs and registration history.
   - Landing page (`/`) features an open event catalog and instant registration form.

3. **Modern & Responsive UI (TailwindCSS)**:
   - Sporty, modern design featuring glassmorphism elements, quota progress indicators, and high-resolution event banners.

---

## 📂 Project Structure & Views

All view templates are organized logically inside `resources/views/`:

```text
resources/views/
├── auth/                      <-- [GUEST AUTHENTICATION]
│   ├── login.blade.php        <-- User & Admin Login Form
│   └── register.blade.php     <-- New Runner Registration Form
│
├── user/                      <-- [PUBLIC EVENT CATALOG]
│   ├── index.blade.php        <-- Public Event Catalog & Remaining Slot Indicators
│   └── show.blade.php         <-- Event Details & Ticket Registration Form
│
├── peserta/                   <-- [RUNNER DASHBOARD]
│   └── dashboard.blade.php    <-- Digital E-BIB & Payment History
│
├── admin/                     <-- [ADMIN DASHBOARD]
│   ├── dashboard.blade.php    <-- Overview Stats, Revenue & Payment Verification
│   └── events/                <-- CRUD Event Management & Quota Slots
│       ├── index.blade.php    <-- Event List & Slot Status Table
│       ├── create.blade.php   <-- Add New Event Form
│       └── edit.blade.php     <-- Edit Event & Quota Form
│
└── layouts/
    └── app.blade.php          <-- Master Layout (Navbar, Header, Footer & Toast Notifications)

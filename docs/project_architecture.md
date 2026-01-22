# Project Architecture: SaaS User Behavior Analysis

## 1. Data Flow Overview
Proyek ini menggunakan pendekatan **ELT (Extract, Load, Transform)** dengan struktur sebagai berikut:

- **Source:** Raw CSV files (Users, Subscriptions, Payments, Activity, Promotions).
- **Staging Layer (`staging` schema):** Data mentah dimuat tanpa perubahan tipe data (Numeric/Text).
- **Analytic Layer (`analytic` schema):** Proses pembersihan, deduplikasi, dan penentuan Surrogate Key.
- **Mart Layer:** Tabel ringkasan (`user_behavior_summary`) untuk konsumsi dashboard.

## 2. Layer Definitions

### A. Staging Layer
Menampung data asli dengan prefix `_raw`. Fokus pada integritas data mentah sebelum diproses.

### B. Analytic Layer
Di sini logika bisnis diterapkan:
- **`dim_users`**: Menghapus orphan users dan mengunci profil statis.
- **`fact_subscriptions`**: Menyelesaikan isu multiple active plans (Deduplikasi).
- **`fact_payments`**: Membersihkan transaksi hantu (Early payments) dan standarisasi promo.
- **`fact_activity`**: Mengonversi log aktivitas menjadi fakta engagement yang bersih.

### C. Mart Layer
Tabel `user_behavior_summary` menggabungkan semua dimensi dan fakta menggunakan `LEFT JOIN` untuk memastikan seluruh basis user (400) terpantau, baik yang aktif maupun pasif.

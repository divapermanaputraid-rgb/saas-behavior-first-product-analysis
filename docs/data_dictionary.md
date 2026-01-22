# Data Dictionary: Analytic Layer (User Behavior & Retention Analysis)

**Schema:** `analytic`  
**Update Terakhir:** 2026-01-22  
**Status:** Final - Implementasi Strategi Pembersihan Data

## 1. Tabel: `dim_users`
**Deskripsi:** Master data profil pengguna unik. Tabel ini adalah jangkar (anchor) untuk semua analisis per-user.  
**Grain:** 1 Baris = 1 User Unik (`user_id`).  
**Total Baris:** 400.

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR | ID unik pengguna. | Dari `staging.users_raw`. |
| `signup_date` | DATE | Tanggal pendaftaran user. | Dari `staging.users_raw`. |
| `acquisition_channel`| VARCHAR | Channel akuisisi (organik/ads). | `LOWER(acquisition_channel)`. |
| `region` | VARCHAR | Wilayah asal user. | `LOWER(region)`. |
| `is_churned` | BOOLEAN | Status apakah user sudah churn. | Mapping string ('true', 'yes', '1') ke Boolean. |
| `is_promo_user` | BOOLEAN | Penanda user hasil akuisisi promo. | **TRUE** jika pembayaran pertama memakai promo. |
| `first_promo_code` | VARCHAR | Kode promo pertama yang digunakan. | Diambil dari transaksi pertama yang valid. |

---

## 2. Tabel: `fact_subscriptions`
**Deskripsi:** Tabel fakta langganan utama (Primary Subscription) per user. Digunakan untuk menghitung potensi pendapatan.  
**Grain:** 1 Baris = 1 User (Deduplicated).  
**Total Baris:** 400.

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `unique_subscription_id`| VARCHAR(32) | Surrogate Key (Unique ID). | `MD5(user_id + sub_id + start_date)`. |
| `user_id` | VARCHAR | Referensi ke `dim_users`. | Dari `staging.subscriptions_raw`. |
| `plan_type` | VARCHAR | Jenis paket langganan. | `LOWER(plan_type)`. |
| `status` | VARCHAR | Status langganan (active/expired). | `LOWER(status)`. |
| `monthly_price` | INT | Harga paket bulanan. | `CAST(monthly_price AS INT)`. |
| `start_date` | DATE | Tanggal mulai langganan. | Dari `staging.subscriptions_raw`. |
| `subscription_duration_days`| INT | Durasi hari aktif langganan. | `end_date - start_date`. |

---

## 3. Tabel: `fact_payments`
**Deskripsi:** Tabel transaksi pembayaran historis. Digunakan untuk menghitung LTV dan ROI Promo.  
**Grain:** 1 Baris = 1 Transaksi Pembayaran.  
**Total Baris:** 3.555 (45 baris dibuang karena data orphan/ghost).

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `unique_payment_id` | VARCHAR(32) | Surrogate Key (Unique ID). | `MD5(user_id + payment_id + date + amount)`. |
| `user_id` | VARCHAR | Referensi ke `dim_users`. | Dari `staging.payments_raw`. |
| `amount` | INT | Nominal pembayaran. | `CAST(amount AS INT)`. |
| `payment_date` | DATE | Tanggal pembayaran dilakukan. | Filter: `payment_date >= signup_date`. |
| `promo_code` | VARCHAR | Kode promo yang digunakan. | Jika tidak terdaftar, labeli `'unknown_promo'`. |

---

## 4. Tabel: `fact_activity`
**Deskripsi:** Catatan harian aktivitas user untuk mengukur Engagement (Stickiness).  
**Grain:** 1 Baris = 1 Hari Aktivitas per User.  
**Total Baris:** 5.664 (342 baris "Ghost Activity" dibuang).

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `unique_activity_id`| VARCHAR(32) | Surrogate Key (Unique ID). | `MD5(user_id + activity_date + count)`. |
| `user_id` | VARCHAR | Referensi ke `dim_users`. | Dari `staging.user_activity_raw`. |
| `activity_date` | DATE | Tanggal aktivitas terjadi. | Filter: `activity_date >= signup_date`. |
| `activity_count` | INT | Jumlah interaksi harian user. | `CAST(activity_count AS INT)`. |

---

## 5. Tabel: `user_behavior_summary`
**Deskripsi:** Tabel Mart (Denormalized) yang merangkum seluruh perilaku pengguna. Digunakan sebagai sumber utama untuk dashboard analisis Churn dan Engagement.  
**Grain:** 1 Baris = 1 User.  
**Total Baris:** 400.

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR | ID unik pengguna. | `dim_users`. |
| `signup_date` | DATE | Tanggal pendaftaran. | `dim_users`. |
| `region` | VARCHAR | Wilayah asal user. | `dim_users`. |
| `acquisition_channel`| VARCHAR | Channel akuisisi. | `dim_users`. |
| `is_promo_user` | BOOLEAN | Indikator user promo. | `dim_users`. |
| `latest_plan_type` | VARCHAR | Paket langganan terakhir. | `COALESCE(fact_subscriptions.plan_type, 'no plan')`. |
| `subscription_status`| VARCHAR | Status langganan terakhir. | `COALESCE(fact_subscriptions.status, 'no subs')`. |
| `is_churned` | BOOLEAN | Status apakah user sudah churn. | `dim_users`. |
| `total_revenue_spent`| INT | Total pendapatan dari user. | `SUM(fact_payments.amount)`. |
| `avg_payment_value` | INT | Rata-rata nilai transaksi. | `AVG(fact_payments.amount)`. |
| `total_interactions` | INT | Total volume aktivitas. | `SUM(fact_activity.activity_count)`. |
| `active_days_count` | INT | Jumlah hari aktif beraktivitas. | `COUNT(fact_activity.activity_date)`. |
| `last_active_date` | DATE | Tanggal terakhir beraktivitas. | `MAX(fact_activity.activity_date)`. |
| `tenure_days` | INT | Durasi loyalitas (hari sejak signup ke aktivitas terakhir). | `last_active_date - signup_date`. |
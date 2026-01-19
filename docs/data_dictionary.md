# Data Dictionary: Analytic Layer (SaaS Subscription Analysis)

**Schema:** `analytic`
**Update Terakhir:** 2026-01-19
**Deskripsi Umum:** Layer ini berisi data yang telah dibersihkan, di-cast tipe datanya, dan siap digunakan untuk perhitungan metrik Churn, Retention, dan LTV.

---

## 1. Tabel: `dim_users`
**Deskripsi:** Master data profil pengguna unik.
**Grain:** 1 Baris = 1 User Unik (`user_id`).

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR | ID unik pengguna. | Dari `staging.users_raw`. |
| `signup_date` | DATE | Tanggal pendaftaran user. | Dari `staging.users_raw`. |
| `acquisition_channel`| VARCHAR | Channel akuisisi (organik/ads). | `LOWER(u.acquisition_channel)`. |
| `region` | VARCHAR | Wilayah asal user. | `LOWER(u.region)`. |
| `is_churned` | BOOLEAN | Status apakah user sudah churn. | `CASE WHEN` string to Boolean mapping. |
| `is_promo_user` | BOOLEAN | Penanda user hasil akuisisi promo. | **TRUE** jika pembayaran pertama ada promo_code. |
| `first_promo_code` | VARCHAR | Kode promo pertama yang digunakan. | Diambil dari `rank_pembayaran = 1`. |

---

## 2. Tabel: `fact_subscriptions`
**Deskripsi:** Tabel fakta langganan utama (Primary Subscription) per user.
**Grain:** 1 Baris = 1 User (Hanya langganan terbaru/utama).

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
**Deskripsi:** Transaksi pembayaran historis yang valid.
**Grain:** 1 Baris = 1 Transaksi Pembayaran.

| Nama Kolom | Tipe Data | Deskripsi | Logika / Source |
| :--- | :--- | :--- | :--- |
| `unique_payment_id` | VARCHAR(32) | Surrogate Key (Unique ID). | `MD5(user_id + payment_id + date + amount)`. |
| `user_id` | VARCHAR | Referensi ke `dim_users`. | Dari `staging.payments_raw`. |
| `amount` | INT | Nominal pembayaran. | `CAST(amount AS INT)`. |
| `payment_date` | DATE | Tanggal pembayaran dilakukan. | Filter: `payment_date >= signup_date`. |
| `promo_code` | VARCHAR | Kode promo yang digunakan. | Jika tidak ada di master, labeli `'unknown_promo'`. |
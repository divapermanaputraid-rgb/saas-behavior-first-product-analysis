# Data Cleaning Strategy: User Behavior & Retention Focus
# Konteks Utama:
 Tujuannya adalah analisis behavioral (Churn & Retention). Dokumen ini menjelaskan strategi pembersihan dan penanganan anomali data sebelum data digunakan pada layer analytic/mart.

### 1. Isu Duplicate ID (Global ID Failure)
* **Temuan:**  `subscription_id ` dan `payment_id` bukan unik global, melainkan penomoran berulang (mungkin per *batch* atau per user)
    contoh:`S001`(143 kali) dan `P001`(285 kali). 
* **Risiko:** jika `JOIN` mentah, akan terjadi data akan meledak, yang membuat metrik jadi kacau
* **strategi**
    * **Composite Key** untuk semua join: kombinasi dari `user_id + subscription_id` atau `user_id + payment_id`
    * Di layer analytic buat **Surrogate** key baru (misal menggunakan `MD5(user_id || subscription_id || start_date)`) agar setiap baris benar benar unik.
    * **Distinct Load** untuk menghapus baris yang kolomnya identik

### 2. Anomali Kronologis (Early Records)
* **Temuan:** ada aktivitas/payment tertanggal sebelum `signup_date`
* **strategi**
    * **filtering** hapus baris aktivitas dan pembayaran yang terjadi sebelum `signup_date`
    * **logika** dalam analysis behavior, tidak bisa menghitung retensi untuk interaksi yang terjadi sebelum user terdaftar. data ini di anggap *noise*
    * ***note*** *Data mentah tetap disimpan di staging untuk keperluan audit/debug.*
    
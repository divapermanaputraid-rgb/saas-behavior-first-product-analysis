# Data Cleaning Strategy: User Behavior & Retention Focus
## Konteks Utama:
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

### 3. Integritas Referensial (Orphan Records)
* **TEmuan:** ada data di Ada transaksi menggantung yang `user_id`-nya tidak terdaftar di tabel master users.
* **strategi**
    * **Skip dari Analytic Layer** hanya simpan data transaksi yang `user_id` ada di tabel `users_raw`
    Orphan records tidak dimasukkan ke analytic layer

    * **Namun:**
        * tetap disimpan di staging
        * dicatat sebagai data quality issue

* **alasan**
    * Analisis behavior mustahil dilakukan tanpa subjek (user).
    * Memasukkan orphan akan mencemari metrik churn & retention

### 4. Promo Handling
* **Temuan:**Transaksi sukses, tapi kode promo yang dipakai tidak ada di promosi.

* **strategi**
    * Transaksi tetap dihitung 
    * Labeli promo sebagai `unknown_promo`

* **alasan**
    * Menghapus payment akan merusak histori transaksi
    * namun promo
        * tidak akan dimasukkan ke analisis efektivitas promo spesifik
    * hanya dihitung sebagai “promo non-terdefinisi”

### 5. Multiple Active Subscriptions
* **Temuan:**Beberapa user memiliki lebih dari satu subscription berstatus `active`

* **strategi**
    * **Primary Subscription** menetapkan satu langganan utama per user.

    * **Aturan Prioritas:** ditentukan
        * Subscription dengan `start_date` paling baru
        * Jika sama, pilih dengan `monthly_price` tertinggi
    
## Prinsip Eksekusi
    * Tidak menghapus raw data di staging
    * pembersihan terjadi saat transformasi ke analytic layer
    * setiap asumsi di catat
    * **prioritas**
    Prioritas kita adalah konsistensi user journey. Jika data tidak logis secara waktu, buang dari analisis, jangan dipaksa masuk.

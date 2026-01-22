## saas-behavior-first-product-analysis
### Context
* produk: SaaS, subscription (simulasi)
* model bisnis: Freemium/Tiered Subscription (Lite / Premium)
* User Activity: Merepresentasikan jumlah interaksi user di dalam aplikasi per hari.

### Analysis Scope & Constraints
* data yang tersedia
    * users
    * subscriptions
    * promotions 
    * payments
    * user_activity
* Data Yang Tidak Tersedia **NO COST DATA**
* Dengan data yang ada, analisis difokuskan pada user behavior dan proxy value. Analisis tidak mencakup ***net revenue***/ ***profitability***

### Business Question
Bagaimana pengaruh Plan Type dan Penggunaan Promo terhadap tingkat Churn dan Loyalitas (Retention) pengguna?

### Data Dictionary
* users :Profil user (signup, channel, region).
* subscriptions: Status langganan (active, canceled) dan harga
* payments: Rekam jejak transaksi dan penggunaan promo code.
* user_activity: Log harian aktivitas user (activity_count).
* promotion: Detail promo dan diskon.

### Initial Hypothesis
* diduga User yang bergabung dengan promo memiliki churn rate lebih tinggi dalam 30 hari pertama dibandingkan user non-promo.
* diduga ada perbedaan pola retention antara user premium dan lite, yang dapat diamati melalui analisis cohort


### Tipe Data pada Staging
Seluruh kolom numerik di staging menggunakan tipe `NUMERIC`.
karena sumber data dari file CSV (export Excel) yang memiliki format angka tidak konsisten (contoh: `50000.0`).

### Proses Import Data
Data mentah (CSV) pada layer staging dimuat secara **manual menggunakan database UI.**
Project ini tidak berfokus pada otomasi ETL, sehingga script SQL hanya mencakup:

* pembuatan skema dan tabel

* transformasi dan analisis data

##  Temuan Kunci & Anomali Data

### Anomali Struktur ID (Critical Data Issue)

Pada proses audit data mentah (staging), ditemukan anomali struktural serius:

- `subscription_id` dan `payment_id` tidak bersifat unik secara global.
- ID yang sama (contoh: `S001`, `P001`) muncul ratusan kali pada user yang berbeda.
- Hal ini mengindikasikan bahwa ID tersebut hanyalah penomoran lokal atau placeholder, bukan primary key sebenarnya.

**Implikasi Analisis:**
- JOIN antar tabel tidak dapat dilakukan hanya berdasarkan `subscription_id` atau `payment_id`.
- JOIN harus selalu dikombinasikan dengan `user_id`, atau menggunakan surrogate key.
- Tanpa penanganan ini, agregasi (MRR, churn, retention) akan mengalami data explosion dan menghasilkan angka yang menyesatkan.

**Keputusan Analitis:**
- Pada layer analitik, dibuat *surrogate key* menggunakan kombinasi atribut (`user_id`, `subscription_id`, `start_date`) untuk menjamin keunikan baris.
- Audit dan cleaning dilakukan sebelum membangun data mart agar validitas analisis perilaku tetap terjaga.

**Detail strategi pembersihan data terdokumentasi pada: `docs/cleaning_strategy.md`.**



##  Preliminary Observations (Under Investigation)
### Status Proyek Saat Ini
> Seluruh temuan berikut bersifat **preliminary** dan dihasilkan sebelum proses pembersihan data final.
> Insight ini digunakan sebagai hipotesis investigasi, bukan kesimpulan bisnis final.

- **Activity Paradox:** Ditemukan bahwa pengguna yang berhenti (*churn*) memiliki rata-rata interaksi (70.1) yang lebih tinggi dibandingkan pengguna aktif (51.0). Proyek ini sedang dalam tahap investigasi mendalam untuk menentukan apakah hal ini disebabkan oleh gesekan pada produk (*product friction*) atau perilaku penyelesaian tugas (*task completion*).
- **Critical Tenure Window:** Mayoritas pengguna memutuskan untuk bertahan atau pergi dalam rentang waktu **14-15 hari** pertama.
* **Insight:** Keputusan user terjadi di minggu kedua. Intervensi produk atau strategi *nurturing* wajib masuk **sebelum hari ke-10** untuk mencegah *drop-off* massal di jendela kritis ini.

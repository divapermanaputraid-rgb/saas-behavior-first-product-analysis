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
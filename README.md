# SaaS Behavior & Subscription Analysis (Product Case Study)

## 1. Context & Business Model
* **Produk:** Simulasi aplikasi SaaS berbasis langganan.
* **Model Bisnis:** Freemium/Tiered Subscription (Lite & Premium).
* **User Activity:** Representasi jumlah interaksi harian pengguna di dalam aplikasi (Engagement).
* **Scope:** Analisis difokuskan pada perilaku pengguna (*user behavior*) dan retensi. Proyek ini tidak mencakup analisis profitabilitas karena ketiadaan data biaya (*cost data*).

## 2. Business Questions
1. Bagaimana pengaruh jenis paket (Plan Type) dan penggunaan promo terhadap tingkat *churn*?
2. Apakah tingkat aktivitas pengguna (Engagement) berbanding lurus dengan loyalitas (Retention)?
3. Di mana jendela kritis (*critical window*) pengguna memutuskan untuk berhenti berlangganan?

## 3. Data Architecture & ETL Strategy
Proyek ini menggunakan struktur tiga lapis untuk menjamin integritas data:
1.  **Staging Layer:** Data mentah dimuat dengan tipe data `NUMERIC` untuk menangani ketidakistirahatan format ekspor CSV/Excel.
2.  **Analytic Layer:** Proses pembersihan besar-besaran, termasuk:
    * **Type Casting:** Mengubah `NUMERIC` menjadi `INT` untuk efisiensi komputasi.
    * **Surrogate Key Generation:** Penggunaan `MD5(user_id + business_key)` untuk menangani ID yang tidak unik secara global (`subscription_id` & `payment_id` yang duplikat).
    * **Time-Series Validation:** Menghapus data "Ghost Activity" (aktivitas yang tercatat sebelum tanggal pendaftaran).
3.  **Mart Layer:** Tabel `user_behavior_summary` sebagai *Single Source of Truth* untuk pelaporan.

## 4. Temuan Kunci & Audit Data (Critical Findings)

### A. Resolved (Analytically): The Activity Paradox
*Catatan: Resolusi ini berlaku dalam konteks data yang telah dibersihkan sesuai strategi yang didefinisikan, dan tidak mengklaim kebenaran absolut di luar dataset simulasi ini.*

* **Temuan Awal:** Analisis awal menunjukkan paradoks di mana pengguna *churn* terlihat lebih aktif daripada pengguna tetap.
* **Hasil Audit Teknis:** Ditemukan kesalahan pelabelan (*labeling mismatch*) pada tahap awal transformasi. Setelah dilakukan audit pada layer analitik, pola perilaku kembali logis:
    * **Active Users (270 user):** Rata-rata **70.14** interaksi per hari.
    * **Churned Users (130 user):** Rata-rata **51.05** interaksi per hari.
* **Kesimpulan:** Pengguna yang bertahan terbukti **37% lebih aktif** dibandingkan pengguna yang berhenti.

### B. Business Logic Anomalies (Current Investigation)
Ditemukan dua anomali serius yang berdampak pada operasional bisnis:
1.  **Subscription Sync Issue (69 User):** Terdapat 69 pengguna yang secara profil berstatus `is_churned = TRUE`, namun sistem billing masih mencatat langganan mereka sebagai `active`. Ini merupakan risiko *chargeback* dan ketidaksinkronan data keuangan.
2.  **Ghost Revenue (12 User):** Terdapat 12 pengguna yang tetap membayar secara rutin namun memiliki **interaksi nol (0)** di aplikasi. Kelompok ini diidentifikasi sebagai pengguna pasif yang berisiko tinggi melakukan *churn* masif di masa mendatang.

### C. Critical Tenure Window
* Rata-rata umur pengguna (*tenure*) berada di angka **14-15 hari**.
* **Insight:** Keputusan kritis pengguna terjadi di minggu kedua. Strategi *nurturing* dan intervensi produk harus dilakukan **sebelum hari ke-10** untuk mencegah *drop-off* pada jendela kritis ini.

## 5. Hasil Analisis Hipotesis & Implikasi Bisnis

Setelah proses pembersihan data dan investigasi anomali, dilakukan evaluasi ulang terhadap hipotesis awal. Bagian ini merangkum temuan utama serta implikasi strategis yang dapat ditarik dari data.

---

### a Pengaruh Promo terhadap Churn  
**Status Hipotesis:** Terkonfirmasi

**Temuan:**
- Pengguna yang bergabung melalui program promo memiliki **Churn Rate 41,24%**.
- Sebagai pembanding, pengguna non-promo memiliki **Churn Rate 29,70%**.

**Interpretasi Analitis:**
Program promo terbukti efektif meningkatkan akuisisi awal, namun juga menarik segmen pengguna dengan kecenderungan loyalitas yang lebih rendah. Pola ini konsisten dengan karakteristik *price-sensitive users* atau *discount-driven acquisition*, di mana keputusan penggunaan tidak sepenuhnya didorong oleh nilai produk.

Tanpa data biaya, analisis LTV tidak dapat dilakukan secara eksplisit. Namun, tingginya churn pada cohort promo mengindikasikan potensi ketidakseimbangan antara biaya akuisisi dan nilai jangka panjang pengguna.

**Implikasi Strategis (Non-Preskriptif):**
- Skema promo berpotensi lebih efektif jika dikaitkan dengan sinyal komitmen jangka menengah (misalnya berbasis durasi penggunaan), dibandingkan diskon langsung di awal.
- Pendekatan ini dapat berfungsi sebagai mekanisme *self-selection* untuk menyaring pengguna dengan intensi penggunaan yang lebih berkelanjutan.

---

### b Performa Paket Premium vs Lite  
**Status Hipotesis:** Tidak Terkonfirmasi

**Temuan:**
- Paket **Premium** mencatat:
  - Churn Rate: **35,2%**
  - Rata-rata interaksi harian: **61,7**
- Paket **Lite** mencatat:
  - Churn Rate: **29,5%**
  - Rata-rata interaksi harian: **66,3**

**Interpretasi Analitis:**
Secara perilaku, pengguna Premium menunjukkan tingkat keterlibatan yang lebih rendah meskipun membayar harga lebih tinggi. Hal ini mengindikasikan adanya potensi *value proposition gap*, di mana manfaat tambahan dari paket Premium tidak tercermin dalam peningkatan penggunaan harian.

Temuan ini tidak serta-merta menunjukkan kegagalan harga, namun membuka kemungkinan bahwa:
- Fitur Premium tidak relevan dalam konteks penggunaan harian, atau
- Kompleksitas fitur justru menambah friksi penggunaan.

**Implikasi Strategis (Non-Preskriptif):**
- Diperlukan evaluasi lebih lanjut terhadap korelasi antara fitur Premium dan aktivitas inti pengguna.
- Analisis lanjutan dapat difokuskan pada *feature-level engagement* untuk mengidentifikasi fitur yang benar-benar mendorong nilai.

---

### c Critical Retention Window: Perspektif Intervensi Dini

**Temuan:**
- Rata-rata *user tenure* berada pada rentang **14–15 hari**.
- Pola ini konsisten di berbagai segmen pengguna.

**Interpretasi Analitis:**
Keputusan untuk bertahan atau berhenti cenderung terjadi sebelum minggu kedua. Dengan demikian, intervensi yang dilakukan setelah titik ini memiliki dampak terbatas terhadap outcome retensi.

**Implikasi Produk:**
- Retensi jangka panjang tampaknya sangat dipengaruhi oleh kecepatan pengguna dalam mencapai *core value* produk.
- Aktivitas dan pengalaman pengguna pada **7 hari pertama** berperan sebagai indikator awal loyalitas.

Temuan ini memberikan dasar analitis untuk mengevaluasi efektivitas onboarding, edukasi fitur, dan pengalaman awal pengguna tanpa mengasumsikan solusi implementatif tertentu.

---

## 6. Dokumentasi Pendukung
* **Cleaning Strategy:** `docs/cleaning_strategy.md`
* **Data Dictionary:** `docs/data_dictionary.md`
* **Investigation Notes:** `docs/investigation_notes.md`
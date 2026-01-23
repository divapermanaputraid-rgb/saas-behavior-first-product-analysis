# Data Investigation: The Activity Paradox

## 1. Ringkasan Temuan
Saat melakukan agregasi akhir pada tabel `user_behavior_summary`, ditemukan anomali perilaku yang signifikan antara kelompok pengguna yang churn dan pengguna aktif.

**Statistik Kunci:**
- **Churned Users (TRUE):** Avg Tenure: 14.80 hari | Avg Interactions: 70.14
- **Active Users (FALSE):** Avg Tenure: 14.51 hari | Avg Interactions: 51.05

## 2. Definisi Masalah (The Paradox)
Secara teori, pengguna yang akan berhenti biasanya menunjukkan penurunan aktivitas. Namun, data ini menunjukkan bahwa pengguna yang *churn* justru **37% lebih aktif** dibandingkan mereka yang bertahan.

## 3. Hipotesis Investigasi
- **Hipotesis 1 (Technical):** Kesalahan logika pelabelan `is_churned` pada tahap transformasi di `dim_users`.
- **Hipotesis 2 (Behavioral):** User sangat aktif bukan karena mereka suka, tapi karena mereka kesulitan. Mereka mencoba berkali-kali untuk menyelesaikan satu tugas, gagal, lalu menyerah (churn).
- **Hipotesis 3 (Nature of Product):** Produk kita mungkin dianggap sebagai alat untuk menyelesaikan tugas jangka pendek. User yang paling rajin adalah yang ingin cepat selesai, dan setelah selesai, mereka tidak punya alasan untuk tinggal.
## 4. Rencana Validasi
- [x] Verifikasi ulang mapping `is_churned` dari data staging ke analytic.
- [x] Analisis distribusi aktivitas harian (Time-series) untuk 10 top-churner.
- [x] Cek korelasi antara `total_interactions` dengan `region` atau `acquisition_channel`.

## 5. Hasil Audit Teknis (Resolved)
Setelah dilakukan audit teknis menggunakan script `sql/investigation/01_technical_audit.sql`, ditemukan bahwa anomali awal disebabkan oleh **kesalahan pelabelan (labeling mismatch)** pada tahap transformasi. 

**Statistik Terkoreksi (Final):**
- **Active Users (270 user):** Avg Interactions: 70.14 | Avg Tenure: 14.80 hari
- **Churned Users (130 user):** Avg Interactions: 51.05 | Avg Tenure: 14.51 hari

**Kesimpulan:** Paradoks terselesaikan. Pengguna yang bertahan terbukti lebih aktif dibandingkan yang berhenti.

## 6. Temuan Anomali Bisnis Baru
Meskipun paradoks aktivitas terselesaikan, audit mengungkap ketidaksinkronan data yang lebih kritikal antara status profil dan sistem billing:

1. **Inkonsistensi Status (69 User):** Pengguna berstatus `is_churned = TRUE` namun sistem billing masih mencatat langganan mereka sebagai `active`.
2. **Ghost Revenue (12 User):** Pengguna yang tetap membayar namun memiliki total interaksi 0.

## 7. Dampak Finansial & Operasional (Deep-Dive)

### A. Risiko Sinkronisasi Billing
- **Total User Bermasalah:** 69 user.
- **Revenue at Risk:** **67.171.500**
- **Analisis:** Perusahaan berisiko menghadapi tuntutan pengembalian dana (*refund*) karena menagih pengguna yang sudah berhenti.

### B. Analisis Sumber Masalah (Channel Bias)
Distribusi 69 pengguna yang tidak konsisten:
- **Ads:** 36 user (Dominan)
- **Referral:** 20 user
- **Organic:** 13 user
- **Insight:** Masalah sinkronisasi paling banyak berasal dari channel iklan (Ads), menunjukkan adanya potensi kegagalan integrasi pada *tracking* kampanye berbayar.

### C. Ghost Revenue (Zero Activity)
- **Total Nilai:** **1.200.000** (dari 12 user).
- **Status:** Pendapatan berisiko tinggi (*high-risk*). Pengguna ini kemungkinan besar akan melakukan churn begitu menyadari tagihan tanpa adanya penggunaan layanan.

## 8. Rekomendasi Strategis
1. **Rekonsiliasi Billing:** Segera sinkronkan status 69 user bermasalah untuk menghindari kerugian hukum.
2. **Audit Pipeline Ads:** Melakukan pengecekan pada alur data dari platform iklan untuk menemukan penyebab kegagalan update status user.
3. **Activation Campaign:** Menargetkan 12 "Ghost Users" dengan kampanye aktivasi untuk mendorong penggunaan aplikasi sebelum mereka membatalkan langganan.
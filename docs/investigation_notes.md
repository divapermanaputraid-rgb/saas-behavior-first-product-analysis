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
- [ ] Verifikasi ulang mapping `is_churned` dari data staging ke analytic.
- [ ] Analisis distribusi aktivitas harian (Time-series) untuk 10 top-churner.
- [ ] Cek korelasi antara `total_interactions` dengan `region` atau `acquisition_channel`.

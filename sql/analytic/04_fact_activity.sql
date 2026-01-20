-- ==========================================================
-- Script: analytic/04_fact_activity.sql
-- Description: Engagement Behavior, Validasi Logika Waktu, generate Surrogate Key, Optimasi Tipe Data, Integritas Referensi 
-- ==========================================================


-- 1. Pembuatan Tabel
CREATE TABLE analytic.fact_activity AS
WITH raw_activity_processed AS (
	SELECT
		user_id,
		activity_date,

		-- Optimasi Tipe Data (Numeric -> Int)
		CAST(activity_count AS INT) AS activity_count
	FROM
		staging.user_activity_raw
	WHERE
		activity_count IS NOT NULL
)

-- Final Logic & Filtering
-- - Surrogate Key (Identitas Unik)
SELECT	
	MD5(CONCAT(r.user_id, r.activity_date, r.activity_count)) AS unique_activity_id,

	r.user_id,
	r.activity_date,
	r.activity_count

-- - anti orphan
FROM
	raw_activity_processed r
INNER JOIN
	analytic.dim_users u ON r.user_id = u.user_id
	
-- - Validasi Kronologi
WHERE
	r.activity_date >= u.signup_date;


-- - Cek Total Baris Bersih (Final Row Count)
SELECT COUNT(*) as total_clean_rows FROM analytic.fact_activity;

-- - Cek Berapa Sampah yang Dibuang
SELECT 
    (SELECT COUNT(*) FROM staging.user_activity_raw) as total_raw,
    (SELECT COUNT(*) FROM analytic.fact_activity) as total_clean,
    (SELECT COUNT(*) FROM staging.user_activity_raw) - 
    (SELECT COUNT(*) FROM analytic.fact_activity) as total_discarded;

-- -  Cek Volume Aktivitas (Data Integrity)
SELECT SUM(activity_count) as total_interactions FROM analytic.fact_activity;
-- - max activity
SELECT MAX(activity_count) AS Max_Activity FROM analytic.fact_activity;
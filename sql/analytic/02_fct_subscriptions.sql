-- ==========================================================
-- Script: analytic/02_fact_subscriptions.sql
-- Description: Optimasi Tipe Data, Generasi Surrogate Key, Kontrol Granularitas,Validasi Referensi, Normalisasi Teks 
-- ==========================================================

-- 1. Pembuatan Tabel
CREATE TABLE analytic.fact_subscriptions AS
-- - Pembersihan & Ranking
WITH ranked_subscriptions AS (
	SELECT
		user_id,
		subscription_id,
		start_date,
		end_date,
		
		-- Standarisasi Text
		LOWER(plan_type) AS plan_type,
		LOWER(status) AS status,

		-- Optimasi Tipe Data (NUMERIC -> INT)
		CAST(monthly_price AS INT) AS monthly_price,

		ROW_NUMBER() OVER (
			PARTITION BY user_id
			ORDER BY start_date DESC, monthly_price DESC
		)AS sub_rank

	FROM 
		staging.subscriptions_raw
)

-- Finalisasi Data
-- - surrogate key (identitas unik)
-- - menggabungkan 3 kolom jadi 1 kode acak unik (MD5)
SELECT 
	MD5(CONCAT(rs.user_id, rs.subscription_id, rs.start_date)) AS unique_subscription_id,

	rs.user_id,
	rs.plan_type,
	rs.status,
	rs.monthly_price,
	rs.start_date,
	rs.end_date,

	-- durasi langganan
	(rs.end_date - rs.start_date) AS subscription_duration_days
FROM
	ranked_subscriptions rs
-- anti orphan, ambil langganan valid dari dim_users
INNER JOIN
	analytic.dim_users u ON rs.user_id = u.user_id
WHERE
rs.sub_rank = 1;
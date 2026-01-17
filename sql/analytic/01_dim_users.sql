-- ==========================================================
-- Script: analytic/01_dim_users.sql
-- Description: Transaksi Pertama, Integrasi Data User, Standarisasi Format, Validasi Kualitas (analytic)
-- ==========================================================

-- 1. tabel dim_users
CREATE TABLE analytic.dim_users AS
-- mencari pembayaran pertama yang valid
WITH first_payment_logic AS (
	SELECT
		p.user_id,
		p.promo_code,
		p.payment_date,

		ROW_NUMBER() OVER (
			PARTITION BY p.user_id
			ORDER BY p.payment_date ASC
		) as payment_rank
	FROM
		staging.payments_raw p
	JOIN
		staging.users_raw u ON p.user_id = u.user_id
	WHERE
		p.payment_date >= u.signup_date
)
-- Menggabungkan User dengan Status Pembayaran Pertamanya
SELECT
	u.user_id,
	u.signup_date,

	LOWER(u.acquisition_channel) AS acquisition_channel,
	LOWER(u.region) AS region,
	LOWER(u.initial_plan) AS initial_plan,

	CASE
		WHEN LOWER(u.source_churn_flag) IN ('true','yes','1') THEN TRUE
		ELSE FALSE
	END AS is_churned,

-- Penentuan User Promo vs Organik
-- Jika pembayaran PERTAMA pakai kode, selamanya dia adalah User Promo
	CASE
		WHEN fp.promo_code IS NOT NULL AND fp.promo_code !='' THEN TRUE
		ELSE FALSE
	END AS is_promo_user,
	COALESCE(fp.promo_code, 'No Promo') as first_promo_code
FROM
	staging.users_raw u
LEFT JOIN
	first_payment_logic fp ON u.user_id = fp.user_id AND fp.payment_rank = 1
WHERE
	u.user_id IS NOT NULL
	
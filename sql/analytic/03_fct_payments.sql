-- ==========================================================
-- Script: analytic/02_fact_payments.sql
-- Description: OPreservasi Granularitas, Handling Missing Dimensions, Optimasi Tipe Data, Validasi Relasi 
-- ==========================================================


-- 1. Pembuatan Tabel
-- - Validation & Transformation Phase
CREATE TABLE analytic.fact_payment AS
WITH raw_payment_processed AS (
	SELECT
		p.payment_id,
		p.user_id,
		p.subscription_id,
		p.payment_date,

		-- tipe data(NUMERIC -> INT)
		CAST(p.amount AS INT) AS amount,
		LOWER(p.payment_status) AS payment_status,

		-- logika promo (Validasi kode promo)
		CASE
			WHEN p.promo_code IS NULL OR p.promo_code = '' THEN NULL
			WHEN pr.promo_code IS NOT NULL THEN p.promo_code -- jika promo code ada ti tabel
			ELSE 'unknown_promo'
		END AS validated_promo_code
	FROM
		staging.payments_raw p

	-- join ke tabel promo untuk validasi
	LEFT JOIN
		staging.promotions_raw pr ON p.promo_code = pr.promo_code
)

-- Final Filtering & Key Generation
-- SURROGATE KEY Identitas Unik Transaksi
SELECT
	MD5(CONCAT(rp.payment_id, rp.user_id, rp.payment_date)) AS unique_payment_id,

	rp.user_id,
	rp.subscription_id,
	rp.payment_date,
	rp.amount,
	rp.payment_status,
	rp.validated_promo_code

FROM
	raw_payment_processed rp
	-- Anti-Orphan
INNER JOIN
	analytic.dim_users u ON rp.user_id = u.user_id
-- - tidak memproses tanpa payment_id
WHERE
	rp.payment_id IS NOT NULL
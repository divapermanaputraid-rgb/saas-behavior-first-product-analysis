-- ==========================================================
-- Script: analytic/05_user_behavior_summary
-- Description: Single Source of Truth, Query Performance, Holistic User View,Null Handling
-- ==========================================================


-- 1. Pembuatan Tabel
DROP TABLE IF EXISTS analytic.user_behavior_sumary;
-- - 1.1 Agregasi Pembayaran
CREATE TABLE analytic.user_behavior_summary AS
WITH payment_summary AS (
	SELECT
		user_id,
		SUM(amount) AS total_revenue_spent,
		CAST(AVG(amount) AS INT) AS avg_payment_value
	FROM
		analytic.fact_payment
	GROUP BY 
		user_id
),

-- - 1.2 Agregasi Aktivitas
activity_summary AS (
	SELECT
		user_id,
		SUM(activity_count) AS total_interactions,
		MAX(activity_date) AS last_active_date,
		COUNT(activity_date) AS active_days_count
	FROM
		analytic.fact_activity
	GROUP BY
		user_id
),

-- - 1.3 Info Langganan
subscription_summary AS (
	SELECT
		user_id,
		plan_type,
		status AS subscription_status
	FROM
		analytic.fact_subscriptions
	
)

--- - Penggabungan Akhir
SELECT
	-- a. IDENTITAS & DIMENSI
	u.user_id,
	u.signup_date,
	u.region,
	u.acquisition_channel,
	u.is_promo_user,

	-- b. STATUS
	COALESCE(s.plan_type, 'no plan') AS lastest_plan_type,
	COALESCE(s.subscription_status, 'no subs') AS subscription_status,
	u.is_churned,

	-- c. MONETARY
	COALESCE(p.total_revenue_spent, 0) AS total_revenue_spent,
	COALESCE(p.avg_payment_value, 0) AS avg_payment_value,

	-- d.ENGAGMENT
	COALESCE(a.total_interactions, 0) AS total_interactions,
	COALESCE(a.active_days_count, 0) AS active_days_count,
	a.last_active_date,

	-- e.TIME FRAME (Menghitung berapa hari sejak daftar sampai terakhir aktif)
	CASE
		WHEN a.last_Active_date IS NOT NULL THEN (a.last_active_date - u.signup_date)
		ELSE 0
	END AS tenure_Days
FROM 
	analytic.dim_users u

-- [STRATEGI JOIN]: LEFT JOIN (mulai dari tabel Users, lalu tempelkan data lain, Jika tidak ada (misal belum pernah bayar), data nilainya NULL)
LEFT JOIN
	subscription_summary s ON u.user_id = s.user_id
LEFT JOIN
	payment_summary p ON u.user_id = p.user_id
LEFT JOIN
	activity_summary a ON u.user_id = a.user_id;


-- FINAL CHECK
-- - Cek Konsistensi Revenue
SELECT
	(SELECT SUM(total_revenue_spent) FROM analytic.user_behavior_summary) AS summary_revenue,
	(SELECT SUM(amount) FROM analytic.fact_payment) AS original_revenue;

-- - Cek Kelengkapan User
SELECT COUNT(*) FROM analytic.user_behavior_summary;

-- Cek User (Zero Value)
SELECT COUNT(*) AS freemium_users
FROM analytic.user_behavior_summary
WHERE total_revenue_spent = 0;

SELECT
	is_churned,
	COUNT(user_id) AS total_user,
	ROUND(AVG(tenure_days), 2) AS avg_tenure_days,
	ROUND(AVG(total_interactions), 2) AS avg_interactions
FROM
	analytic.user_behavior_summary
GROUP BY
	1;
-- ==========================================================
-- INVESTIGASI FASE 1: TECHNICAL AUDIT
-- Tujuan: Memastikan tidak ada kesalahan logika mapping atau duplikasi data (fan-out)
-- ==========================================================

-- TEST 1: Verifikasi Mapping Churn
SELECT
	s.source_churn_flag,
	a.is_churned,
	COUNT(*) AS total_user
FROM staging.users_raw s
JOIN analytic.dim_users a ON s.user_id = a.user_id
GROUP BY 1, 2;


SELECT
	a.user_id
FROM analytic.dim_users a
JOIN analytic.fact_subscriptions s
  ON a.user_id = s.user_id
WHERE a.is_churned = TRUE
  AND s.status = 'active';

  
-- TEST 2: cek duplikasi di fact_activity
SELECT
	user_id,
	activity_date,
	COUNT(*) AS duplicate_count
FROM analytic.fact_activity
GROUP BY 1, 2
HAVING COUNT(*) > 1;

-- TEST 3:validasi agresi di summary
SELECT
	(SELECT SUM(total_revenue_spent) FROM analytic.user_behavior_summary) AS summary_revenue,
	(SELECT SUM(amount) FROM analytic.fact_payment) AS fact_revenue,
	(SELECT SUM(total_interactions) FROM analytic.user_behavior_summary) AS summary_interactions,
	(SELECT SUM(activity_count) FROM analytic.fact_activity) AS fact_interactions;

-- TEST 4:Cardinality Check 
SELECT
	COUNT(*) AS joined_rows,
	COUNT(DISTINCT u.user_id) AS unique_users
FROM analytic.dim_users u
JOIN analytic.fact_subscriptions s
  ON u.user_id = s.user_id;

-- TEST 5:Revenue Leakage Check
SELECT
	f.user_id
FROM analytic.fact_payment f
LEFT JOIN analytic.user_behavior_summary s
  ON f.user_id = s.user_id
WHERE s.user_id IS NULL;

-- TEST 6:Zero-Activity Paying Users
SELECT
	p.user_id
FROM analytic.fact_payment p
LEFT JOIN analytic.fact_activity a
  ON p.user_id = a.user_id
WHERE a.user_id IS NULL;
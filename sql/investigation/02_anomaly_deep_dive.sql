-- ==========================================================
-- INVESTIGASI FASE 2: DEEP DIVE ANOMALI BISNIS
-- ==========================================================

-- TEST 1: Menghitung Total Kerugian/Potensi Revenue dari 69 User Inconsistent
SELECT
	is_churned,
	subscription_status,
	COUNT(user_id) AS total_user,
	SUM(total_revenue_Spent) AS revenue_At_risk
FROM
	analytic.user_behavior_summary
WHERE
	is_churned = TRUE AND subscription_status = 'active'
GROUP BY 1,2;

-- TEST 2: Analisis Channel pada Kelompok Bermasalah
SELECT
	acquisition_channel,
	COUNT(user_id) AS total_inconsistent_users
FROM
	analytic.user_behavior_summary
WHERE
	is_churned = TRUE AND subscription_Status = 'active'
GROUP BY 1
ORDER BY 2 DESC;

-- TEST 3: Revenue dari Ghost Users (Zero Activity)
SELECT
	SUM(total_revenue_spent) AS total_ghost_revenue
FROM
	analytic.user_behavior_summary
WHERE
	total_interactions = 0 AND total_revenue_spent > 0;
-- ==========================================================
-- Script: mart/02_plan_performance
-- Description:Analisis Hipotesis 2: Performa Paket (Lite vs Premium) 
-- ==========================================================

-- Analisis Hipotesis 2: Performa Paket (Lite vs Premium)
SELECT
	lastest_plan_type,
	COUNT(user_id) AS total_user,
	ROUND(AVG(tenure_days), 2) AS avg_tenure,
	ROUND(AVG(total_interactions), 2) AS avg_engagement,
	SUM(CASE WHEN is_churned = TRUE THEN 1 ELSE 0 END) AS churned_count
FROM
	analytic.user_behavior_summary
GROUP BY 1;

-- evaluasi
-- hasil hipotesis patah (terbalik)
-- - Churn rate: prem (35,2%) lite (29.5%)
-- - user lite (66,36%) lebih aktif dari user prem (61,74%)

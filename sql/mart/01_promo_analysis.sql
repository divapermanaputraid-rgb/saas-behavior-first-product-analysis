-- ==========================================================
-- Script: mart/01_promo_analysis.sql
-- Description: Analisis Hipotesis 1 (Dampak Promo terhadap Churn)


-- Analisis Hipotesis 1: Dampak Promo terhadap Churn
SELECT
	is_promo_user,
	COUNT(user_id) AS total_user,
	SUM(CASE WHEN is_churned = TRUE THEN 1 ELSE 0 END) AS churned_count,
	ROUND(
		CAST(SUM(CASE WHEN is_churned = TRUE THEN 1 ELSE 0 END) AS DECIMAL) /
		CAST(COUNT(user_id) AS DECIMAL) * 100,
		2
	) AS churn_rate_percetage,
	ROUND(AVG(total_revenue_spent), 0) AS avg_ltv
FROM
	analytic.user_behavior_summary
GROUP BY 1;

-- evaluasi 
-- hasil hipotesis benar,
-- - churn rate user promo (41,24%) non promo (29,70%)
-- - analisis 11,54 "discount hunter" 
-- - avg LTV user promo (870.541) lebih tinggi dari avg LTV (858.312)

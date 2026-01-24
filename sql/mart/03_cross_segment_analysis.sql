-- ==========================================================
-- Script: mart/03_cross_segment_analysis.sql
-- Description:The Worst Combination (Churn Tertinggi), The Gold Segment (Churn Terendah)
-- ==========================================================

SELECT
    lastest_plan_type,
    is_promo_user,
    COUNT(user_id) AS total_user,
    ROUND(
        CAST(SUM(CASE WHEN is_churned = TRUE THEN 1 ELSE 0 END) AS DECIMAL) / 
        CAST(COUNT(user_id) AS DECIMAL) * 100, 
        2
    ) AS churn_rate_percentage
FROM 
    analytic.user_behavior_summary
GROUP BY 1, 2
ORDER BY 4 DESC;
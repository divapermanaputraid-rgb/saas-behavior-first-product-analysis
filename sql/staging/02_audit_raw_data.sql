-- ==========================================================
-- Project: SaaS Behavior-First Product Analysis
-- Script: 02_audit_raw_data.sql
-- Description: Audit Integritas, Validitas, dan Kualitas Data Mentah (Staging)
-- ==========================================================


-- 1. Validasi Jumlah Baris (Row Count)
SELECT 'users' as tabel, COUNT(*) FROM staging.users_raw
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM staging.subscriptions_raw
UNION ALL
SELECT 'payments', COUNT(*) FROM staging.payments_raw
UNION ALL
SELECT 'activity', COUNT(*) FROM staging.user_activity_raw
UNION ALL
SELECT 'promotions', COUNT(*) FROM staging.promotions_raw;

-- 2. Cek Duplikasi ID (Uniqueness Check)
-- Staging tidak pakai Primary Key, jadi kita harus cek manual.
SELECT
	user_id,
	COUNT(*) AS jumlah_duplikat
FROM 
	staging.users_raw
GROUP BY
	user_id
HAVING
	COUNT(*)>1;
	
-- Cek Duplikasi Baris subscription_id (Duplicate Check)
SELECT
	subscription_id,
	COUNT(*) AS jumlah_duplikat
FROM 
	staging.subscriptions_raw
GROUP BY
	subscription_id
HAVING
	COUNT(*)>1;

-- cek duplikasi baris payment_id
SELECT
	payment_id,
	COUNT(*) AS jumlah_duplikat
FROM 
	staging.payments_raw
GROUP BY
	payment_id
HAVING
	COUNT(*)>1;

-- 3. Cek Data Hilang / NULL (Nullity Check)
-- Fokus pada kolom kunci yang tidak boleh kosong
SELECT 'users' as tabel, COUNT(*) as null_count FROM staging.users_raw WHERE user_id IS NULL
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM staging.subscriptions_raw WHERE subscription_id IS NULL OR user_id IS NULL
UNION ALL
SELECT 'payments', COUNT(*) FROM staging.payments_raw WHERE payment_id IS NULL OR user_id IS NULL;

SELECT DISTINCT source_churn_flag, initial_plan
FROM staging.users_raw;

-- 4. Cek Validitas Tanggal (Date Validity)
-- Memastikan rentang waktu masuk akal.
-- A. End Date sebelum Start Date (Subscriptions)
SELECT 
	subscription_id,
	user_id,
	start_date,
	end_date
FROM
	staging.subscriptions_raw
WHERE
	end_date < start_date;

-- B. End Date sebelum Start Date (Promotions)
SELECT 
	promo_code,
	start_date,
	end_date
FROM
	staging.promotions_raw
WHERE
	end_date < start_date;

-- 5. Cek Logika Bisnis (Business Logic Check)
-- Memastikan urutan kejadian masuk akal.
SELECT
	p.payment_id,
	p.user_id,
	p.payment_date,
	u.signup_date
FROM
	staging.payments_raw p
JOIN
	staging.users_raw u ON p.user_id = u.user_id
WHERE
	p.payment_date < u.signup_date;

-- B. Aktivitas sebelum User mendaftar
SELECT
	a.user_id,
	a.activity_date,
	u.signup_date
FROM
	staging.user_activity_raw a
JOIN
	staging.users_raw u ON a.user_id = u.user_id
WHERE
	a.activity_date < u.signup_date;

-- 6. Cek Keutuhan Referensi (Referential Integrity / Orphan Records)
-- Mencari data yang tidak punya "induk" di tabel users.


SELECT
	s.subscription_id,
	s.user_id
FROM
	staging.subscriptions_raw s
LEFT JOIN
	staging.users_raw u ON s.user_id = u.user_id
WHERE
	u.user_id IS NULL;

-- -  A. Orphan Subscriptions
SELECT
	p.payment_id,
	p.subscription_id
FROM 
	staging.payments_raw p
LEFT JOIN
	staging.subscriptions_raw s ON p.subscription_id = s.subscription_id
WHERE 
	s.subscription_id IS NULL;

-- - B. Orphan Payments
SELECT
	p.payment_id,
	p.user_id
FROM
	staging.payments_raw p
LEFT JOIN
	staging.users_raw u ON p.user_id = u.user_id
WHERE
	u.user_id IS NULL;

-- -C. Orphan Activity
SELECT
	a.user_id,
	a.activity_date
FROM
	staging.user_activity_raw a
LEFT JOIN
	staging.users_raw u ON a.user_id = u.user_id
WHERE
	u.user_id IS NULL;

-- - D. Orphan Promo Codes
SELECT
	p.payment_id,
	p.promo_code
FROM 
	staging.payments_raw p
LEFT JOIN
	staging.promotions_raw pr ON p.promo_code = pr.promo_code
WHERE
	p.promo_code IS NOT NULL		--abaikan yang bayar harga normal
	AND pr.promo_code IS NULL		--cari yang codenya tidak ada di promotions

-- Activity Tanpa Subscription
SELECT DISTINCT
	a.user_id
FROM
	staging.user_activity_raw a
LEFT JOIN
	staging.subscriptions_raw s
ON a.user_id = s.user_id
WHERE 
	s.user_id IS NULL;

-- Consistency Check
SELECT *
FROM
	staging.users_raw u
JOIN
	staging.subscriptions_raw s ON u.user_id = s.user_id
WHERE
	u.source_churn_flag = 'true'
AND
	s.status = 'active';

-- Multiple Active Subscription
SELECT
	user_id,
	COUNT(*) AS active_sub_count
FROM
	staging.subscriptions_raw
WHERE
	status = 'active'
GROUP BY 
	user_id
HAVING 
	COUNT(*) > 1;

-- -Outlier Check (Proxy Value Distortion)
SELECT *
FROM
	staging.user_activity_raw
WHERE
	activity_count < 0
	OR activity_count >1000;

SELECT *
FROM
	staging.payments_raw
WHERE
	amount < 0;


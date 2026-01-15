-- 01_init_staging.sql

-- 1.1_Create tables staging.users_raw

CREATE TABLE staging.users_raw (
user_id VARCHAR(50),
signup_date DATE,
acquisition_channel VARCHAR(20),
region VARCHAR(50),
initial_plan VARCHAR(20),
source_churn_flag VARCHAR(20)
);

-- 1.2_Create Tables staging.subscriptions_raw
CREATE TABLE staging.subscriptions_raw(
subscription_id VARCHAR(50),
user_id VARCHAR(50),
plan_type VARCHAR(10),
start_date DATE,
end_date DATE,
status VARCHAR(10),
monthly_price NUMERIC
);

-- 1.3_Create Tables staging.payments_raw
CREATE TABLE staging.payments_raw(
payment_id VARCHAR(50),
user_id VARCHAR(50),
subscription_id VARCHAR(50),
payment_date DATE,
amount NUMERIC,
promo_code VARCHAR(50),
payment_status VARCHAR(10)
);

-- 1.4_Create Tables staging.user_activity_raw
CREATE TABLE staging.user_activity_raw(
user_id VARCHAR(50),
activity_date DATE,
activity_count INT
);

-- 1.5_Create Tables staging.promotions_raw
CREATE TABLE staging.promotions_raw(
promo_code VARCHAR(50),
discount_type VARCHAR(20),
discount_value NUMERIC,
start_date DATE,
end_date DATE
);

-- Catatan:
-- -type data
-- Semua kolom numerik di staging menggunakan NUMERIC
-- karena data CSV berasal dari export Excel (contoh: 50000.0).
-- Normalisasi tipe data dilakukan di layer analytic.

-- -import data
-- Data staging dimuat secara manual melalui database UI.
-- File ini hanya berisi definisi tabel (tanpa INSERT / COPY).

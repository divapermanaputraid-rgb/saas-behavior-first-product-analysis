-- _BOOTSTRAP.SQL
-- One-time environment setup

-- 01_create database
CREATE DATABASE "saas_behavior_first_product_analysis"

-- 02_create_schemas.sql
CREATE SCHEMA staging;
CREATE SCHEMA reference;
CREATE SCHEMA analytic;
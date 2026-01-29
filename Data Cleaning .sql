
--- Finding and removing DUPLICATES from cities ---

select * from cities;

select city_id, city_name, telecom_circle_name, city_tire, urban_rural_flag, count(*) as cnt
from cities
group by city_id, city_name, telecom_circle_name, city_tire, urban_rural_flag
having count(*)>1;


WITH CTE AS ( SELECT city_id, city_name, telecom_circle_name, region_name, city_tire, urban_rural_flag, 
ROW_NUMBER() OVER ( PARTITION BY city_id, city_name,  telecom_circle_name, region_name, city_tier, urban_rural_flag 
ORDER BY city_id ) AS rank_value 
FROM cities)
DELETE FROM cities
WHERE (city_id, city_name, telecom_circle_name, region_name, city_tire, urban_rural_flag) IN (
SELECT city_id, city_name, telecom_circle_name, region_name, city_tire, urban_rural_flag
FROM CTE
WHERE rank_value > 1
);


--- Finding and removing DUPLICATES from customer_status_duplicate---

SELECT * FROM Customer_status;

SELECT status_data_key, customer_id, customer_status, churn_reason, compitetor_name, rank_value
FROM (SELECT status_data_key, customer_id, customer_status, churn_reason, compitetor_name,
ROW_NUMBER() OVER (PARTITION BY status_data_key, customer_id, customer_status, churn_reason, compitetor_name ORDER BY status_data_key) AS rank_value
FROM customer_status) AS row_number_value
WHERE rank_value > 1;

WITH CTE AS (SELECT status_data_key, customer_id, customer_status, churn_reason, compitetor_name,
ROW_NUMBER() OVER (PARTITION BY status_data_key, customer_id, customer_status, churn_reason, compitetor_name ORDER BY status_data_key) AS rank_value
FROM customer_status
)
DELETE FROM customer_status
WHERE (status_data_key, customer_id, customer_status, churn_reason, compitetor_name)
IN (SELECT status_data_key, customer_id, customer_status, churn_reason, compitetor_name
FROM CTE
WHERE rank_value > 1
);

--- Finding and removing DUPLICATES from customers---

SELECT * FROM (SELECT*, ROW_NUMBER() OVER (PARTITION BY customer_id, customer_age, customer_gender, city_identifier, activation_date, customer_type,
user_segment, kyc_status, sim_type) AS rank_value FROM customer ORDER BY customer_id) AS row_number_value
WHERE rank_value > 1;

WITH CTE AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id, customer_age, customer_gender, city_identifier, activation_date, customer_type, user_segment, 
kyc_status, sim_type ORDER BY customer_id) AS rank_value 
FROM customer
) 
DELETE FROM customer
WHERE (customer_id, customer_age, customer_gender, city_identifier, activation_date, customer_type, user_segment, kyc_status, sim_type) 
IN (SELECT customer_id, customer_age, customer_gender, city_identifier, activation_date, customer_type, user_segment, kyc_status, sim_type 
FROM CTE 
WHERE rank_value > 1
);


--- Finding and removing DUPLICATES from daily_usage---

Select * from daily_usage;

SELECT * FROM ( SELECT *, ROW_NUMBER() OVER(PARTITION BY date_key, customer_id, plan_id, data_allocated_mb,data_carried_forward_mb, 
	data_consumed_mb, voice_minutes_used, sms_used, network_type, usage_source ORDER BY date_key) AS rank_value FROM daily_usage) AS row_number_value
WHERE rank_value>1;

WITH CTE AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY date_key, customer_id, plan_id, data_allocated_mb, data_carried_forward_mb, data_consumed_mb, 
	voice_minutes_used, sms_used, network_type, usage_source ORDER BY date_key) AS rank_value 
FROM daily_usage AS row_number_value 
) 
DELETE FROM daily_usage
WHERE (date_key, customer_id, plan_id, data_allocated_mb,
data_carried_forward_mb, data_consumed_mb, voice_minutes_used, sms_used, network_type, usage_source) 
IN (SELECT date_key, customer_id, plan_id, data_allocated_mb, data_carried_forward_mb, data_consumed_mb, voice_minutes_used, sms_used, network_type, usage_source
FROM CTE 
WHERE rank_value > 1
);

--- Finding and removing DUPLICATES from date_duplicate---

SELECT * FROM date;

SELECT * FROM (SELECT *, ROW_NUMBER () OVER (PARTITION BY date_key, date_value, year, month_number, month_name,
quarter, week_of_year, day_of_week_number, day_of_week_name, is_weekend_flag) AS rank_value FROM date)
AS row_number_value
WHERE rank_value > 1;


--- Finding and removing DUPLICATES from market_share_duplicate---

SELECT * FROM market_share;

SELECT * FROM ( SELECT *, ROW_NUMBER () OVER(PARTITION BY month, telecom_circle_name, operator_name, market_share_percentage, active_subscribers)
AS rank_value FROM market_share ORDER BY month) AS row_number_value
WHERE rank_value > 1;

--- Finding and removing DUPLICATES from plan_duplicate---


SELECT * FROM plan;

SELECT * FROM ( SELECT *, ROW_NUMBER () OVER(PARTITION BY plan_id, plan_name, customer_type, plan_validity_days, daily_data_limit_gb, 
monthly_data_allowance_gb, voice_unlimited_flag, rollover_allowed_flag, fair_usage_policy_limit_gb, plan_category, plan_launch_date, plan_discontinued_date
ORDER BY plan_id) AS rank_value FROM plan_duplicate) AS row_number_value
WHERE rank_value > 1;


ALTER TABLE plan
ADD COLUMN plan_row_id BIGINT AUTO_INCREMENT PRIMARY KEY;

WITH CTE AS ( SELECT plan_row_id,
ROW_NUMBER() OVER (PARTITION BY plan_id, plan_name, customer_type, plan_validity_days, daily_data_limit_gb, 
monthly_data_allowance_gb, voice_unlimited_flag, rollover_allowed_flag, fair_usage_policy_limit_gb, plan_category, plan_launch_date, plan_discontinued_date
ORDER BY plan_row_id) AS rn
FROM plan
) 
DELETE FROM plan
WHERE plan_row_id IN (SELECT plan_row_id FROM cte WHERE rn > 1);

--- Finding and removing DUPLICATES from plan_revenue_duplicate---

SELECT * FROM plan_revenue;

SELECT * FROM ( SELECT *, ROW_NUMBER () OVER(PARTITION BY billing_id, billing_month, customer_id, plan_id, billed_amount_inr,
discount_applied_inr, late_fee_inr, refund_amount_inr, net_revenue_inr, billing_status) AS rank_value FROM plan_revenue)
AS row_number_value
WHERE rank_value >1;

WITH CTE AS ( SELECT billing_id, ROW_NUMBER () OVER(PARTITION BY billing_id, billing_month, customer_id, plan_id, billed_amount_inr,
discount_applied_inr, late_fee_inr, refund_amount_inr, net_revenue_inr, billing_status ORDER BY billing_id) AS rank_value
FROM plan_revenue)

DELETE FROM plan_revenue
WHERE billing_id 
IN ( SELECT billing_id 
FROM CTE
WHERE rank_value > 1
);

WITH CTE AS ( SELECT *, ROW_NUMBER () OVER(PARTITION BY billing_id, billing_month, customer_id, plan_id, billed_amount_inr,
discount_applied_inr, late_fee_inr, refund_amount_inr, net_revenue_inr, billing_status ORDER BY billing_id) AS rank_value
FROM plan_revenue)
SELECT COUNT(*)
FROM CTE
WHERE rank_value > 1;


--- STANDARDISING DATA---

--- Standardising data for cities ---

SELECT * FROM cities;
UPDATE cities
SET city_id = COALESCE(city_id, 0),
city_name = COALESCE(NULLIF(TRIM(city_name), ''), 'Not Available'),
telecom_circle_name = COALESCE(NULLIF(TRIM(telecom_circle_name),' '), 'Not Available'),
region_name = COALESCE(NULLIF(TRIM(region_name), ''), 'Not Available'),
city_tire = COALESCE(NULLIF(TRIM(city_tire), ''), 'Not Available'),
urban_rural_flag = COALESCE(NULLIF(TRIM(urban_rural_flag), ''), 'Not Available');

--- Standardising data for customer_status ---
SELECT * FROM customer_status;
UPDATE customer_status
SET status_data_key = COALESCE(status_data_key, 0),
customer_id = COALESCE(customer_id, 0),
Customer_status = COALESCE(NULLIF(TRIM(Customer_status), ''), 'Not Available'),
churn_reason = COALESCE(NULLIF(TRIM(churn_reason), ''), 'Not Available'),
compitetor_name = COALESCE(NULLIF(TRIM(compitetor_name), ''), 'Not Available');


--- Standardising data for customers ---
SELECT * FROM customer;
UPDATE customer
SET customer_id = COALESCE(customer_id,0),
customer_age = COALESCE(customer_age, 0),
customer_gender = COALESCE(NULLIF(TRIM(customer_gender), ''), 'Not Available'),
city_identifier = COALESCE(city_identifier, 0),
activation_date = COALESCE(activation_date, '1900-11-01'),
customer_type = COALESCE(NULLIF(TRIM(customer_type), ''), 'Not Available'),
user_segment = COALESCE(NULLIF(TRIM(user_segment), ''), 'Not Available'),
kyc_status = COALESCE(NULLIF(TRIM(kyc_status), ''), 'Not Available'),
sim_type = COALESCE(NULLIF(TRIM(sim_type), ''), 'Not Available');


--- Standardising data for daily_usage ---
SELECT * FROM daily_usage;
UPDATE daily_usage
SET date_key = COALESCE(date_key, 0),
customer_id = COALESCE(customer_id, 0),
plan_id = COALESCE(plan_id, 0),
data_allocated_mb = COALESCE(data_allocated_mb, 0),
data_carried_forward_mb = COALESCE(data_carried_forward_mb, 0),
data_consumed_mb = COALESCE(data_consumed_mb, 0),
voice_minutes_used = COALESCE(voice_minutes_used, 0),
sms_used = COALESCE(sms_used, 0),
network_type = COALESCE(NULLIF(TRIM(network_type), ''), 'Not Available'),
usage_source = COALESCE(NULLIF(TRIM(usage_source), ''), 'Not Available');


--- Standardising data for date ---
SELECT * FROM date;
UPDATE date
SET date_key = COALESCE(date_key, 0),
date_value = COALESCE(date_value, '1900-11-01'),
year = COALESCE(year, 0000),
month_number = COALESCE(month_number, 0),
month_name = COALESCE(NULLIF(TRIM(month_name), ''), 'Not Available'),
quarter = COALESCE(quarter, 0),
week_of_year = COALESCE(week_of_year, 00),
day_of_week_number = COALESCE(day_of_week_number, 0),
day_of_week_name = COALESCE(NULLIF(TRIM(day_of_week_name), ''), 'Not Available'),
is_weekend_flag = COALESCE(is_weekend_flag, 'Not Available');

--- Standardising data for market_share ---

SELECT * FROM market_share;
UPDATE market_share
SET month = COALESCE(month, 0000-00),
telecom_circle_name = COALESCE(NULLIF(TRIM(telecom_circle_name), ''), 'Not Available'),
operator_name = COALESCE(NULLIF(TRIM(operator_name), ''), 'Not Available'),
market_share_percentage = COALESCE(market_share_percentage, 0.0),
active_subscribers = COALESCE(active_subscribers, 0);

--- Standardising data for plan ---
SELECT * FROM plan;
UPDATE plan
SET plan_id = COALESCE(plan_id, 0),
plan_name = COALESCE(NULLIF(TRIM(plan_name), ''), 'Not Available'),
customer_type = COALESCE(NULLIF(TRIM(customer_type), ''), 'Not Available'),
plan_validity_days = COALESCE(plan_validity_days, 0),
daily_data_limit_gb = COALESCE(daily_data_limit_gb, 0),
monthly_data_allowance_gb = COALESCE(monthly_data_allowance_gb, 0),
voice_unlimited_flag = COALESCE(NULLIF(TRIM(voice_unlimited_flag), ''), 'Not Available'),
rollover_allowed_flag = COALESCE(NULLIF(TRIM(rollover_allowed_flag), ''), 'Not Available'),
fair_usage_policy_limit_gb = COALESCE(fair_usage_policy_limit_gb, 0),
plan_category = COALESCE(NULLIF(TRIM(plan_category), ''), 'Not Available'),
plan_launch_date = COALESCE(NULLIF(TRIM(plan_launch_date), ''), '1900-11-01'),
plan_discontinued_date = COALESCE(NULLIF(TRIM(plan_discontinued_date), ''), '1900-11-01');

--- Standardising data for plan_revenue---
SELECT * FROM plan_revenue;

UPDATE plan_revenue
SET billing_id = COALESCE(billing_id, 0),
billing_month = COALESCE(billing_month, 0),
customer_id = COALESCE(customer_id, 0),
plan_id = COALESCE(plan_id, 0),
billed_amount_inr = COALESCE(billed_amount_inr, 0),
discount_applied_inr = COALESCE(discount_applied_inr, 0),
late_fee_inr = COALESCE(late_fee_inr, 0),
refund_amount_inr = COALESCE(refund_amount_inr, 0),
net_revenue_inr = COALESCE(net_revenue_inr, 0),
billing_status = COALESCE(NULLIF(TRIM(billing_status), ''), 'Not Available');

SELECT * FROM cities;
SELECT * FROM customer_status;
SELECT * FROM customers;
SELECT * FROM daily_usage;
SELECT * FROM date;
SELECT * FROM market_share;
SELECT * FROM market_share;
SELECT * FROM plan;
SELECT * FROM plan;
SELECT * FROM plan_revenue;

--- Verifying NULLS and EMPTY SPACES in all tables---

--- Verification for cities ---
SELECT * FROM cities;
SELECT COUNT(*) AS rows_with_issues
FROM cities
WHERE city_id IS NULL
OR city_name IS NULL OR TRIM(city_name) = ''
OR telecom_circle_name IS NULL OR TRIM(telecom_circle_name) = ''
OR region_name IS NULL OR TRIM(region_name) = ''
OR city_tire IS NULL OR TRIM(city_tire) = ''
OR urban_rural_flag IS NULL OR TRIM(urban_rural_flag) = '';

--- Verification for customer_status ---

SELECT * FROM customer_status;

SELECT COUNT(*) AS rows_with_issues
FROM customer_status
WHERE status_data_key IS NULL
OR customer_id IS NULL OR TRIM(customer_id) = ''
OR customer_status IS NULL OR TRIM(customer_status) = ''
OR churn_reason IS NULL OR TRIM(churn_reason) = ''
OR compitetor_name IS NULL OR TRIM(compitetor_name) = '';


--- Verification for customer ---
SELECT * FROM customer;

SELECT COUNT(*) AS rows_with_issues
FROM customer
WHERE customer_id IS NULL OR TRIM(customer_id) = ''
OR customer_age IS NULL
OR customer_gender IS NULL OR TRIM(customer_gender) = ''
OR city_identifier IS NULL
OR activation_date IS NULL 
OR customer_type IS NULL OR TRIM(customer_type) = ''
OR user_segment IS NULL OR TRIM(user_segment) = ''
OR kyc_status IS NULL OR TRIM(kyc_status) = ''
OR sim_type IS NULL OR TRIM(sim_type) = '';


--- Verification for daily_usage ---
SELECT * FROM daily_usage;

SELECT COUNT(*) AS rows_with_issues
FROM daily_usage
WHERE date_key IS NULL
OR customer_id IS NULL OR TRIM(customer_id) = ''
OR plan_id IS NULL
OR data_allocated_mb IS NULL
OR data_carried_forward_mb IS NULL
OR data_consumed_mb IS NULL
OR voice_minutes_used IS NULL
OR sms_used IS NULL
OR network_type IS NULL OR TRIM(network_type) = ''
OR usage_source IS NULL OR TRIM(usage_source) = '';

--- Verification for date ---
SELECT * FROM date;

SELECT COUNT(*) AS rows_with_issues
FROM date
WHERE date_key IS NULL 
OR date_value IS NULL 
OR year IS NULL 
OR month_number IS NULL
OR month_name IS NULL OR TRIM(month_name) = ''
OR quarter IS NULL
OR week_of_year IS NULL OR TRIM(week_of_year) = ''
OR day_of_week_number IS NULL
OR day_of_week_name IS NULL OR TRIM(day_of_week_name) = ''
OR is_weekend_flag IS NULL OR TRIM(is_weekend_flag) = '';


--- Verification for market_share ---

SELECT * FROM market_share;

SELECT COUNT(*) AS rows_with_issues
FROM market_share
WHERE month IS NULL 
OR telecom_circle_name IS NULL OR TRIM(telecom_circle_name) = ''
OR operator_name IS NULL OR TRIM(operator_name) = ''
OR market_share_percentage IS NULL
OR active_subscribers IS NULL;

--- Verification for plan ---
SELECT * FROM plan ;
SELECT COUNT(*) AS rows_with_issues
FROM plan
WHERE plan_id IS NULL
OR plan_name IS NULL OR TRIM(plan_name) = ''
OR customer_type IS NULL OR TRIM(customer_type) = ''
OR plan_validity_days IS NULL
OR daily_data_limit_gb IS NULL
OR monthly_data_allowance_gb IS NULL
OR voice_unlimited_flag IS NULL OR TRIM(voice_unlimited_flag) = ''
OR rollover_allowed_flag IS NULL OR TRIM(rollover_allowed_flag) = ''
OR fair_usage_policy_limit_gb IS NULL
OR plan_category IS NULL OR TRIM(plan_category) = ''
OR plan_launch_date IS NULL 
OR plan_discontinued_date IS NULL;

--- Verification for plan_revenue ---
SELECT * FROM plan_revenue;

SELECT COUNT(*) AS rows_with_issues
FROM plan_revenue
WHERE billing_id IS NULL OR TRIM(billing_id) = ''
OR billing_month IS NULL 
OR customer_id IS NULL OR TRIM(customer_id) = ''
OR plan_id IS NULL 
OR billed_amount_inr IS NULL
OR discount_applied_inr IS NULL
OR late_fee_inr IS NULL
OR refund_amount_inr IS NULL
OR net_revenue_inr IS NULL
OR billing_status IS NULL OR TRIM(billing_status) = '';


--- UPDATING DATE COLUMNS---

ALTER table plan_revenue
MODIFY billing_month DATE;

UPDATE plan_revenue
SET billing_month = STR_TO_DATE(CONCAT(billing_month, '-01'), '%Y-%m-%d');

ALTER TABLE date
MODIFY date_value DATE;

UPDATE date
SET date_value = STR_TO_DATE(date_value, '%d-%m-%Y');

ALTER TABLE date
MODIFY date_value DATE;
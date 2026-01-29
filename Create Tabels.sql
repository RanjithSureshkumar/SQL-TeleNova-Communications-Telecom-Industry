USE Telecom;

---Create Table---
CREATE TABLE Cities(
city_id int,
city_name varchar(50),
telecom_circle_name varchar(50),
region_name varchar(50),
city_tire varchar(50),
urban_rural_flag varchar (50)
);

CREATE TABLE Customer_status( 
status_data_key int,
customer_id varchar (50),
customer_status varchar (50),
churn_reason varchar (50),
compitetor_name varchar (50)
);

CREATE TABLE Customer (
customer_id varchar (50),
customer_age int,
customer_gender varchar (50),
city_identifier int,
activation_date text,
customer_type varchar (50),
user_segment varchar (50),
kyc_status varchar (50),
sim_type varchar(50)
);

CREATE TABLE daily_usage(
date_key int,
customer_id varchar (50),
plan_id int,
data_allocated_mb int,
data_carried_forward_mb int,
data_consumed_mb int,
voice_minutes_used int,
sms_used int,
network_type varchar (50),
usage_source varchar(50)
);


CREATE TABLE date(
date_key varchar (50),
date_value varchar (50),
year int,
month_number int,
month_name varchar (50),
quarter int,
week_of_year varchar (10),
day_of_week_number int,
day_of_week_name varchar (50),
is_weekend_flag varchar (50)
);

CREATE TABLE market_share( 
month varchar (20),
telecom_circle_name varchar (100),
operator_name varchar (50),
market_share_percentage decimal (6,2),
active_subscribers int
);

CREATE TABLE plan_revenue(
billing_id VARCHAR (50),
billing_month VARCHAR (50),
customer_id VARCHAR (50),
plan_id VARCHAR (50),
billed_amount_inr DECIMAL(12,2),
discount_applied_inr DECIMAL(12,2),
late_fee_inr DECIMAL(12,2),
refund_amount_inr DECIMAL(12,2),
net_revenue_inr INT NULL,
billing_status VARCHAR(50)
);

CREATE TABLE plan (
   plan_id INT,
   plan_name VARCHAR(50),
   customer_type VARCHAR(50),
   plan_validity_days INT,
   daily_data_limit_gb INT NULL,
   monthly_data_allowance_gb INT NULL,
   voice_unlimited_flag VARCHAR(50),
   rollover_allowed_flag VARCHAR(50),
   fair_usage_policy_limit_gb INT,
   plan_category VARCHAR(50),
   plan_launch_date varchar (50),
   plan_discontinued_date varchar (50)
);


---CREATE DUPLICATE TABLES---










































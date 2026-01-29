-- For each telecom circle, identify the operator with the highest number of active subscribers.
-- Cross Check
	Select * from 
	(SELECT telecom_circle_name, operator_name,sum(active_subscribers) as users,
	row_number() over(partition by telecom_circle_name  order by sum(active_subscribers) desc) as rnk
	from market_share
	group by telecom_circle_name, operator_name) as ranked;
	
-- Customer & Subscriber Analysis
-- How many active costumers do we have by customer type?
SELECT customer_type, count(distinct customer_id) as total_customers
from customer
group by customer_type;

-- Customer distribution by region and urban/rural
select C.city_tire, C.urban_rural_flag,
count(distinct Cu.customer_id) as Total_Users
from Cities C
join Customer Cu 
on Cu.city_identifier = C.city_id
group by C.city_tire,C.urban_rural_flag
order by Total_Users Desc;

-- Usage & Consumption Analysis
-- Total Subscribers by network type
SELECT
  network_category,
  COUNT(*) AS total_users
FROM ( 
  SELECT
    customer_id,
    CASE
      WHEN COUNT(DISTINCT network_type) = 2 THEN 'Both'
      WHEN MAX(network_type) = '4G' THEN '4G Only'
      WHEN MAX(network_type) = '5G' THEN '5G Only'
    END AS network_category
  FROM daily_usage
  GROUP BY customer_id
) t
GROUP BY network_category;

-- total data consumption per customer
SELECT 
    customer_id,
    network_type,
    sum(data_consumed_mb) AS total_daily_data_mb
FROM daily_usage
GROUP BY customer_id,network_type
order by 1,2,3;

-- Which telecom circles generate the highest ARPU?

SELECT 
    ci.telecom_circle_name,
	SUM(pr.net_revenue_inr) as Total_Revenue,
    COUNT(DISTINCT pr.customer_id) as No_of_Cusomers,
    ROUND(SUM(pr.net_revenue_inr) / NULLIF(COUNT(DISTINCT pr.customer_id), 0), 2) AS arpu
FROM plan_revenue pr
JOIN Customer c ON pr.customer_id = c.customer_id
JOIN Cities ci ON c.city_identifier = ci.city_id
WHERE pr.billing_status in ('Billed','Adjusted')
GROUP BY ci.telecom_circle_name
ORDER BY arpu DESC;

-- ARPU (Average Revenue Per User) by customer type
SELECT 
    c.customer_type,
    ROUND(AVG(pr.net_revenue_inr), 2) AS arpu
FROM plan_revenue pr
JOIN Customer c 
    ON pr.customer_id = c.customer_id
GROUP BY c.customer_type;

-- Most popular plans by subscriber count
SELECT 
    p.plan_name,
    COUNT(DISTINCT du.customer_id) AS subscribers
FROM daily_usage du
JOIN plan p 
    ON du.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY subscribers DESC;

-- Plan revenue contribution
SELECT 
    p.plan_name,
    SUM(pr.net_revenue_inr) AS total_revenue
FROM plan_revenue pr
JOIN plan p 
    ON pr.plan_id = p.plan_id
where pr.billing_status in ('Billed', 'Adjusted')
GROUP BY p.plan_name
ORDER BY total_revenue DESC;


-- Which plans have the lowest data utilisation ratio?
-- Recheck
SELECT 
    d.plan_id,
    ROUND(
        AVG(d.data_consumed_mb * 1.0) / NULLIF(p.monthly_data_allowance_gb * 1024, 0),
        3
    ) AS utilisation_ratio
FROM daily_usage d
JOIN plan p ON d.plan_id = p.plan_id
GROUP BY d.plan_id, p.monthly_data_allowance_gb
ORDER BY utilisation_ratio ASC;


-- Which customer segments generate high revenue but low data usage?

WITH usage_summary AS (
    SELECT 
        customer_id,
        round(AVG(data_consumed_mb),2) AS avg_data_usage
    FROM daily_usage
    GROUP BY customer_id
)
SELECT 
    c.user_segment,
    SUM(pr.net_revenue_inr) AS total_revenue,
    round(AVG(u.avg_data_usage),2) AS avg_data_usage
FROM customer c
JOIN plan_revenue pr ON c.customer_id = pr.customer_id
JOIN usage_summary u ON c.customer_id = u.customer_id
where pr.billing_status in ('Billed', 'Adjusted')
GROUP BY c.user_segment
ORDER BY total_revenue DESC;

-- What is the churn rate by telecom circle?
SELECT 
    ci.telecom_circle_name,
    ROUND(
        COUNT(CASE WHEN cs.customer_status = 'Churned' THEN 1 END) * 1.0
        / COUNT(DISTINCT cs.customer_id),
        2
    )*100 AS churn_rate_percentage
FROM customer_status cs
JOIN customer c ON cs.customer_id = c.customer_id
JOIN cities ci ON c.city_identifier = ci.city_id
GROUP BY ci.telecom_circle_name
ORDER BY churn_rate_percentage DESC;

-- Churn & Retention Analysis
-- Overall churn rate
SELECT 
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN customer_status = 'Churned' THEN customer_id END)
        / COUNT(DISTINCT customer_id),
    2) AS churn_rate_percentage
FROM Customer_status;

-- Top churn reasons
SELECT 
    churn_reason,
    COUNT(*) AS churn_count
FROM Customer_status
WHERE customer_status = 'Churned'
GROUP BY churn_reason
ORDER BY churn_count DESC;

-- Churn by competitor
SELECT 
    compitetor_name,
    COUNT(*) AS churned_customers
FROM Customer_status
WHERE customer_status = 'Churned'
GROUP BY compitetor_name
ORDER BY churned_customers DESC;



-- Which plans show high subscriber volume but low ARPU?

SELECT 
    pr.plan_id,
    COUNT(DISTINCT pr.customer_id) AS subscriber_count,
    ROUND(
        SUM(pr.net_revenue_inr) / NULLIF(COUNT(DISTINCT pr.customer_id), 0),
        2
    ) AS arpu
FROM plan_revenue pr
WHERE pr.net_revenue_inr != 'refunded'
GROUP BY pr.plan_id
HAVING COUNT(DISTINCT pr.customer_id) > 100
ORDER BY arpu ASC;


-- How does data usage differ across plan categories?
SELECT 
    p.plan_category,
    ROUND(AVG(d.data_consumed_mb), 2) AS avg_data_usage_mb
FROM daily_usage d
JOIN plan p ON d.plan_id = p.plan_id
GROUP BY p.plan_category
ORDER BY avg_data_usage_mb DESC;

-- Which customer types cause the highest revenue leakage?
SELECT c.customer_type,
SUM(pr.discount_applied_inr + pr.refund_amount_inr) AS revenue_leakage
FROM customer c
JOIN plan_revenue pr
ON c.customer_id = pr.customer_id
WHERE pr.net_revenue_inr != 'refunded'
GROUP BY c.customer_type
ORDER BY revenue_leakage DESC;


-- Which plans are operationally unsustainable long-term?

SELECT d.plan_id,
ROUND(sum(d.data_consumed_mb), 2)/ (1*1024) AS avg_data_usage_GB,
SUM(pr.net_revenue_inr) AS total_revenue
FROM daily_usage d
JOIN plan_revenue pr
ON d.customer_id = pr.customer_id
WHERE pr.net_revenue_inr != 'refunded'
GROUP BY d.plan_id
ORDER BY avg_data_usage_GB DESC;


-- Data Cleaning & Assessment
-- assessing the data
SELECT *
FROM streaming.video;


-- checking for null values
SELECT 
    sum(case when canceled_date is null or canceled_date = '' then 1 else 0 end) as null_canceled_date,
    sum(case when subscription_cost is null or subscription_cost = '' then 1 else 0 end) as null_subscription_cost,
    sum(case when  subscription_interval is null or subscription_interval = '' then 1 else 0 end) as null_subscription_interval,
    sum(case when was_subscription_paid is null or was_subscription_paid = '' then 1 else 0 end) as null_subscription_paid
FROM streaming.video;

-- creating a new column as subscription status
SELECT 
	ï»¿customer_id,
    created_date,
    canceled_date,
    subscription_cost,
    subscription_interval,
    was_subscription_paid,
    CASE
    WHEN canceled_date = NULL or canceled_date = '' THEN 'Active'
    ELSE 'Canceled'
    END  AS subscription_status
FROM streaming.video;

-- count of active and canceled user
SELECT 
	CASE 
    WHEN canceled_date = '' THEN 'Active'
    ELSE 'Canceled'
    END AS subscription_status,
    count(*) AS user_count
FROM streaming.video
GROUP BY subscription_status;

-- Business Questions
-- Question 1 
-- How have MavenFlix subscriptions trended over time?
-- New Subscription by Month
SELECT
	date_format(created_date, '%Y-%m') AS subscription_month,
    count(*) AS new_subscriptions
FROM streaming.video
GROUP BY subscription_month
ORDER BY subscription_month;

-- Cancellation Trend by Month
SELECT
	date_format(canceled_date, '%Y-%m') AS cancellation_month,
    count(*) AS canceled_subscriptions
FROM streaming.video
WHERE canceled_date IS NOT NULL
GROUP BY cancellation_month
ORDER BY cancellation_month;

-- Question 2 
-- What percentage of customers have subscribed for 5 months or more?
SELECT 
  COUNT(*) AS total_customers,
  COUNT(CASE 
           WHEN TIMESTAMPDIFF(MONTH, created_date, IFNULL(canceled_date, CURDATE())) >= 5 
           THEN 1 
        END) AS customers_5_plus_months,
  ROUND(
    (COUNT(CASE 
              WHEN TIMESTAMPDIFF(MONTH, created_date, IFNULL(canceled_date, CURDATE())) >= 5 
              THEN 1 
           END) * 100.0) 
    / COUNT(*), 
  2) AS percent_subscribed_5_months_or_more
FROM streaming.video;

-- Question 3
-- What month had the highest subscriber retention, and the lowest?

-- Highest retention month
SELECT * FROM (
  SELECT 
    DATE_FORMAT(created_date, '%Y-%m') AS subscription_month,
    COUNT(*) AS total_subscribers,
    COUNT(CASE WHEN canceled_date = '' THEN 1 END) AS active_subscribers,
    ROUND(
      (COUNT(CASE WHEN canceled_date = '' THEN 1 END) * 100.0) / COUNT(*), 
      2
    ) AS retention_rate
  FROM streaming.video
  GROUP BY subscription_month
) AS monthly_retention
ORDER BY retention_rate DESC
LIMIT 1;

-- Lower retention month
SELECT * FROM (
  SELECT 
    DATE_FORMAT(created_date, '%Y-%m') AS subscription_month,
    COUNT(*) AS total_subscribers,
    COUNT(CASE WHEN canceled_date = '' THEN 1 END) AS active_subscribers,
    ROUND(
      (COUNT(CASE WHEN canceled_date = ''  THEN 1 END) * 100.0) / COUNT(*), 
      2
    ) AS retention_rate
  FROM streaming.video
  GROUP BY subscription_month
) AS monthly_retention
ORDER BY retention_rate ASC
limit 1;


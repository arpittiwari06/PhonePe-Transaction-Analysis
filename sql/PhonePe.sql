-- Query 1: Calculate the Total Number of Registered Users on the PhonePe Platform.

SELECT
    COUNT(*) AS total_registered_users
FROM all_users;

-- Query 2: Calculate the Total Number of Transactions Processed on the Platform.

SELECT
    COUNT(*) AS total_transactions
FROM all_transactions;

-- Query 3: Calculate the Total Transaction Value Processed Across the Platform.

SELECT
    ROUND(SUM(amount),2) AS total_transaction_value
FROM all_transactions;

-- Query 4: Calculate the Average Transaction Value.

SELECT
    ROUND(AVG(amount),2) AS average_transaction_value
FROM all_transactions;

-- Query 5: Identify the Highest Value Transaction Recorded.

SELECT
    transaction_id,
    user_id,
    amount,
    service,
    service_type,
    transaction_date
FROM all_transactions
ORDER BY amount DESC
LIMIT 1;

-- Query 6: Calculate the Overall Payment Success Rate of the Platform.

SELECT
ROUND(
SUM(CASE
        WHEN payment_status='Successful' THEN 1
        ELSE 0
    END)*100.0/COUNT(*),2
) AS payment_success_rate;

-- Query 7: Calculate the Average Transaction Amount for Each PhonePe Service.
 
 SELECT
    service,
    ROUND(AVG(amount),2) AS average_transaction_amount
FROM all_transactions
GROUP BY service
ORDER BY average_transaction_amount DESC;

-- Query 8: Calculate the Total Spending of Every Registered User Across All Transactions.

SELECT
    u.user_id,
    u.name,
    ROUND(SUM(t.amount),2) AS total_spending
FROM all_users u
JOIN all_transactions t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY total_spending DESC;

-- Query 9: Identify the Top 10 Highest Spending Users on the Platform.
SELECT
    u.user_id,
    u.name,
    ROUND(SUM(t.amount),2) AS total_spending
FROM all_users u
JOIN all_transactions t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY total_spending DESC
LIMIT 10;

-- Query 10: Calculate the Total Number of Transactions Performed by Every User.

SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS total_transactions
FROM all_users u
JOIN all_transactions t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY total_transactions DESC;

-- Query 11: Identify Users Who Registered but Never Performed Any Transaction.
SELECT
    u.user_id,
    u.name,
    u.join_date
FROM all_users u
LEFT JOIN all_transactions t
ON u.user_id = t.user_id
WHERE t.user_id IS NULL;

-- Query 12: Identify the Most Valuable Customer Based on Lifetime Transaction Value.
SELECT
    u.user_id,
    u.name,
    ROUND(SUM(t.amount),2) AS lifetime_value
FROM all_users u
JOIN all_transactions t
ON u.user_id = t.user_id
GROUP BY u.user_id, u.name
ORDER BY lifetime_value DESC
LIMIT 1;

-- Query 13: Calculate the Total Number of Failed Transactions for Every User.
SELECT
    u.user_id,
    u.name,
    COUNT(*) AS failed_transactions
FROM all_users u
JOIN all_transactions t
ON u.user_id = t.user_id
WHERE t.payment_status = 'Failed'
GROUP BY u.user_id, u.name
ORDER BY failed_transactions DESC;

-- Query 14: Analyze Month-over-Month Revenue Growth.
WITH monthly_revenue AS
(
SELECT
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    SUM(amount) AS revenue
FROM all_transactions
GROUP BY
YEAR(transaction_date),
MONTH(transaction_date)
)

SELECT
    year,
    month,
    revenue,
    LAG(revenue)
    OVER(ORDER BY year,month) AS previous_month,
    revenue-
    LAG(revenue)
    OVER(ORDER BY year,month) AS revenue_growth
FROM monthly_revenue;

-- Query 15:Identify the most popular payment service
SELECT
service,
COUNT(*) AS transactions
FROM all_transactions
GROUP BY service
ORDER BY transactions DESC
LIMIT 1;

-- Query 16:Identify the Users Spending Above Average.
SELECT
u.user_id,
u.name,
SUM(amount) AS spending
FROM all_users u
JOIN all_transactions t
ON u.user_id=t.user_id
GROUP BY u.user_id,u.name
HAVING spending >
(
SELECT AVG(total_amount)
FROM
(
SELECT SUM(amount) AS total_amount
FROM all_transactions
GROUP BY user_id
) x
);

-- Query 17: Categorize Users into High, Medium, and Low Spending Segments.
SELECT
    u.user_id,
    u.name,
    SUM(t.amount) AS total_spending,

CASE
WHEN SUM(t.amount)>=50000 THEN 'High Value'
WHEN SUM(t.amount)>=20000 THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment
FROM all_users u
JOIN all_transactions t
ON u.user_id=t.user_id
GROUP BY u.user_id,u.name;
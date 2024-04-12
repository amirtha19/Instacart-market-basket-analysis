--- Most bought product

-- Top 5 products ordered
SELECT TOP 5
    product_id,
    product_name,
    COUNT(product_id) OVER (ORDER BY product_id) AS cnt
FROM
    prior_orders
GROUP BY
    product_id,
    product_name
ORDER BY
    cnt DESC;

-- How many orders placed in each day of the week?
SELECT
    order_dow,
    COUNT(order_id)
FROM
    prior_orders
GROUP BY
    order_dow;

-- What time do the users mostly shop?
SELECT
    order_hour_of_day,
    COUNT(order_id)
FROM
    prior_orders
GROUP BY
    order_hour_of_day;

-- What time and day most users shop?
SELECT TOP 5
    order_hour_of_day,
    COUNT(order_id) AS cnt
FROM
    prior_orders
GROUP BY
    order_hour_of_day
ORDER BY
    cnt DESC;

SELECT TOP 5
    order_hour_of_day,
    COUNT(order_id) AS cnt
FROM
    prior_orders
GROUP BY
    order_hour_of_day
ORDER BY
    cnt ASC;

-- What is the average days users take to shop?
SELECT
    AVG(days_since_prior_order) AS avg_
FROM
    prior_orders;

-- How does order volume vary between weekdays and weekends?
WITH order_dates AS (
    SELECT
        order_id,
        order_dow,
        CASE
            WHEN order_dow IN (0, 1) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type
    FROM
        prior_orders
)
SELECT
    day_type,
    COUNT(DISTINCT order_id) AS order_count
FROM
    order_dates
GROUP BY
    day_type;

-- Star customers
SELECT
    user_id,
    COUNT(order_id) AS cnt
FROM
    prior_orders
ORDER BY
    cnt DESC;

-- Which product is reordered the most?
SELECT TOP 10
    product_id,
    product_name,
    SUM(reordered) AS cnt
FROM
    prior_orders
WHERE
    product_id IS NOT NULL
GROUP BY
    product_name,
    product_id
ORDER BY
    cnt DESC;

-- What is the most ordered product in each department?
WITH cte1 AS (
    SELECT
        department,
        product_name,
        RANK() OVER (PARTITION BY department ORDER BY COUNT(product_id) DESC) AS rnk
    FROM
        prior_orders
    GROUP BY
        department,
        product_name
)
SELECT
    department,
    product_name
FROM
    cte1
WHERE
    rnk = 1;

-- How many customers have placed orders in every department?
WITH cte AS (
    SELECT
        user_id,
        COUNT(DISTINCT product_id) AS cnt
    FROM
        prior_orders
    GROUP BY
        user_id
)
SELECT
    COUNT(user_id) AS cnt_user_all_department
FROM
    cte
WHERE
    cnt = (SELECT COUNT(DISTINCT department) FROM prior_orders);

-- What is the average number of products per order?
SELECT
    AVG(num_products) AS avg_num_products
FROM
    (
        SELECT
            order_id,
            COUNT(*) AS num_products
        FROM
            prior_orders
        GROUP BY
            order_id
    ) AS order_product_counts;

-- How many unique customers have placed orders?
SELECT
    COUNT(DISTINCT user_id) AS cnt_users
FROM
    prior_orders;

-- Products most sold at the day and night
WITH order_hour_category AS (
    SELECT
        *,
        CASE
            WHEN order_hour_of_day >= 6 AND order_hour_of_day < 12 THEN 'morning'
			WHEN order_hour_of_day >= 12 AND order_hour_of_day <= 18 THEN 'midday'
            ELSE 'night'
        END AS hour_category
    FROM
        prior_orders
),
cte AS (
    SELECT
        department,
        hour_category,
        COUNT(product_id) AS cnt,
        RANK() OVER (PARTITION BY department, hour_category ORDER BY COUNT(product_id) DESC) AS rnk
    FROM
        order_hour_category
    GROUP BY
        department,
        hour_category
)
SELECT
    *
FROM
    cte
WHERE
    rnk < 5;

-- Highest reorder_ratio department
SELECT
    department,
    AVG(reordered) AS mean_reordered
FROM
    prior_orders
GROUP BY
    department;

-- What product is ordered first?
WITH tmp AS (
    SELECT
        product_id,
        add_to_cart_order,
        COUNT(*) AS count
    FROM
        prior_orders
    GROUP BY
        product_id,
        add_to_cart_order
),
tmp_pct AS (
    SELECT
        product_id,
        count,
        CAST(count AS FLOAT) / SUM(count) OVER (PARTITION BY add_to_cart_order) AS pct
    FROM
        tmp
    WHERE
        add_to_cart_order = 1 AND count > 10
),
tmp_top AS (
    SELECT
        *,
        RANK() OVER (ORDER BY pct DESC) AS rnk
    FROM
        tmp_pct
)
SELECT
    p.product_name,
    t.pct,
    t.count
FROM
    tmp_top t
JOIN
    products p ON t.product_id = p.product_id
WHERE
    t.rnk <= 10;

--- Products bought together

WITH ProductPairs AS (
SELECT
pp1.product_id AS product_id_1,
pp2.product_id AS product_id_2, COUNT(*) AS frequency
FROM
dbo.order_products__prior AS pp1 INNER JOIN dbo.order_products__prior AS pp2 ON pp1.order_id = pp2.order_id AND pp1.product_id <
pp2.product_id
GROUP BY
pp1.product_id,
pp2.product_id
)
SELECT TOP 10
pp.product_id_1,
pp.product_id_2,
p1.product_name AS product_name_1,
p2.product_name AS product_name_2, pp.frequency
FROM
ProductPairs AS pp
INNER JOIN products AS p1
ON pp.product_id_1= p1.product_id
INNER JOIN products AS p2
ON pp.product_id_2 = p2.product_id
ORDER BY
pp.frequency DESC;

--- Frequent customers
WITH Frequenct_customers AS (
SELECT
user_id,
COUNT(order_id) AS purchase_count
FROM
ORDERS
GROUP BY
user_id
),cs as (
SELECT
user_id,
purchase_count,
CASE
WHEN purchase_count >= 10 THEN 'Frequent Buyer'
WHEN purchase_count >= 5 AND purchase_count < 10 THEN 'Regular Buyer'
ELSE 'Occasional Buyer'
END AS customer_segment
FROM
Frequenct_customers)

select customer_segment,sum(purchase_count) as total
from cs
group by customer_segment;

--- Calculate the customer churn rate calculation
WITH InactiveCustomers AS (
    SELECT
        COUNT(DISTINCT user_id) AS InactiveCount
    FROM (
        SELECT
            user_id,
            MAX(days_since_prior_order) AS max_days_since_prior
        FROM
            Orders
        GROUP BY
            user_id
    ) AS Subquery
    WHERE
        max_days_since_prior >= 30 OR max_days_since_prior IS NULL
)
SELECT
    InactiveCount * 100.0 / NULLIF((SELECT COUNT(DISTINCT user_id) FROM Orders), 0) AS ChurnRate
FROM
    InactiveCustomers;


--- Customer Churn Prediction - number of customers who haven't placed an order in the last 30 days

SELECT COUNT(DISTINCT user_id) AS InactiveCustomers FROM (
    SELECT user_id, MAX(days_since_prior_order) AS max_days_since_prior
    FROM Orders
    GROUP BY user_id
) AS Subquery
WHERE max_days_since_prior >= 30 OR max_days_since_prior IS NULL;


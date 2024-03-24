--- Most bought product

--- Top 5 products ordered

select top 5 product_id,product_name,count(product_id) over (order by product_id) as cnt
from prior_orders
group by product_id,product_name
order by cnt desc;

--- How many orders placed in each day of the week ? 

select order_dow,count(order_id)
from prior_orders
group by order_dow;

--- What time do the users mostly shop ?

select order_hour_of_day,count(order_id)
from prior_orders
group by order_hour_of_day;

--- What time and day most users shop ?

select top 5 order_hour_of_day,count(order_id) as cnt
from prior_orders
group by order_hour_of_day
order by cnt desc;
select top 5 order_hour_of_day,count(order_id) as cnt
from prior_orders
group by order_hour_of_day
order by cnt asc;
--- What is the average days users take to shop ?
select avg(days_since_prior_order) as avg_
from prior_orders;

--- How does order volume vary between weekdays and weekends?
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


--- Star customers

select user_id,count(order_id) as cnt
from prior_orders
order by cnt desc;


--- Which product is reordered the most ?
select top 10 product_id,product_name,sum(reordered) as cnt
from prior_orders
where product_id is not null
group by product_name,product_id
order by cnt desc;

---What is the most ordered product in each department?


with cte1 as (select department,product_name, rank() over (partition by department order by count(product_id) desc) as rnk
from prior_orders
GROUP BY
        department,
        product_name)
select department,product_name from cte1
where rnk =1

---How many customers have placed orders in every department?

with cte as (select user_id,count(distinct product_id) as cnt
from prior_orders 
group by user_id)

select count(user_id) as cnt_user_all_department
from cte
where  cnt = (select count(distinct department) from prior_orders)

---What is the average number of products per order?

SELECT AVG(num_products) AS avg_num_products
FROM (
    SELECT order_id, COUNT(*) AS num_products
    FROM prior_orders
    GROUP BY order_id
) AS order_product_counts;


---How many unique customers have placed orders?

select count(distinct user_id) as cnt_users
from prior_orders

---Products most sold at the day and night
WITH order_hour_category AS (
    SELECT
        *,
        CASE
            WHEN order_hour_of_day >= 6 AND order_hour_of_day < 12 THEN 'morning'
			when order_hour_of_day >=12 and order_hour_of_day <=18 then 'midday'
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
        department, hour_category
)
SELECT
    *
FROM
    cte
WHERE
    rnk < 5;



-- highest reorder_ratio department

SELECT
    department,
    AVG(reordered) AS mean_reordered
FROM
    prior_orders
GROUP BY
    department;

-- What product is ordered first ?

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

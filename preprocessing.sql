
use Instacart;

--Data Integrity

-- Count the number of missing values in the 'days_since_prior_order' 
SELECT COUNT(*) AS MissingValues FROM ORDERS WHERE days_since_prior_order IS NULL;

-- Remove duplicate entries in the 'products' 
DELETE FROM products WHERE product_id NOT IN ( SELECT MIN(product_id) FROM products GROUP BY product_name );

-- Remove duplicate entries in the 'PRODUCTS' 
DELETE FROM PRODUCTS WHERE product_id NOT IN ( SELECT MIN(product_id) FROM PRODUCTs GROUP BY product_name);

-- Set NULL values in the 'days_since_prior_order' 
UPDATE ORDERS SET days_since_prior_order = NULL WHERE days_since_prior_order = '';

-- Set NULL values in the 'order_hour_of_day' 
UPDATE ORDERS SET order_hour_of_day = NULL WHERE order_hour_of_day = '';


--- Asiles

select count(*) as aisle_count from aisles;

--- Department

select count(*) as department_count from departments

---- Products

select count(*) as product_count from products

--- Orders

select count(*) as orders_count from orders;

--- JOIN PRODUCTS AND ORDERS
SELECT *
FROM aisles
WHERE PATINDEX('%[a-zA-Z]%', aisle_id) > 0;

-- Delete the rows where keys are mixed with strings
DELETE FROM products
WHERE PATINDEX('%[a-zA-Z]%', department_id) > 0 or PATINDEX('%[a-zA-Z]%', aisle_id) > 0;

Alter table products
Alter column department_id int;

alter VIEW curr_orders AS 
(select orders.order_id,user_id,products.product_id,order_number,order_dow,order_hour_of_day,days_since_prior_order,add_to_cart_order,product_name,aisle,department,reordered
from orders
inner join order_products__train
on orders.order_id = order_products__train.order_id
inner join products
on products.product_id=order_products__train.product_id
inner join departments
on departments.department_id = products.department_id
inner join aisles
on aisles.aisle_id = products.aisle_id);

alter view prior_orders as (select orders.order_id,user_id,products.product_id,order_number,order_dow,order_hour_of_day,days_since_prior_order,add_to_cart_order,product_name,aisle,department,reordered
from orders
inner join order_products__prior
on orders.order_id = order_products__prior.order_id
inner join products
on products.product_id=order_products__prior.product_id
inner join departments
on departments.department_id = products.department_id
inner join aisles
on aisles.aisle_id = products.aisle_id);

--- View null values
SELECT COUNT(*)
FROM orders
WHERE days_since_prior_order IS NULL;

select top 5 *
from prior_orders
where product_id is null


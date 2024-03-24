
use Instacart;
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

create VIEW curr_orders AS 
(select orders.order_id,user_id,products.product_id,order_number,order_dow,order_hour_of_day,days_since_prior_order,add_to_cart_order,product_name,aisle,department,reordered
from orders
inner join order_products__train
on orders.order_id = order_products__train.order_id
left join products
on products.product_id=order_products__train.product_id
left join departments
on departments.department_id = products.department_id
left join aisles
on aisles.aisle_id = products.aisle_id);

create view prior_orders as (select orders.order_id,user_id,products.product_id,order_number,order_dow,order_hour_of_day,days_since_prior_order,add_to_cart_order,product_name,aisle,department,reordered
from orders
left join order_products__prior
on orders.order_id = order_products__prior.order_id
left join products
on products.product_id=order_products__prior.product_id
left join departments
on departments.department_id = products.department_id
left join aisles
on aisles.aisle_id = products.aisle_id);

--- View null values
SELECT COUNT(*)
FROM orders
WHERE days_since_prior_order IS NULL;

select top 5 *
from prior_orders
where product_id is null
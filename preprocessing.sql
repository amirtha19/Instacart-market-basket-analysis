USE Instacart;

-- Data Integrity

-- Count the number of missing values in the 'days_since_prior_order' column
SELECT COUNT(*) AS MissingValues FROM ORDERS WHERE days_since_prior_order IS NULL;

-- Remove duplicate entries in the 'products' table
DELETE FROM products WHERE product_id NOT IN (SELECT MIN(product_id) FROM products GROUP BY product_name);

-- Remove duplicate entries in the 'PRODUCTS' table
DELETE FROM PRODUCTS WHERE product_id NOT IN (SELECT MIN(product_id) FROM PRODUCTS GROUP BY product_name);

-- Set NULL values in the 'days_since_prior_order' column
UPDATE ORDERS SET days_since_prior_order = NULL WHERE days_since_prior_order = '';

-- Set NULL values in the 'order_hour_of_day' column
UPDATE ORDERS SET order_hour_of_day = NULL WHERE order_hour_of_day = '';

-- Aisles

SELECT COUNT(*) AS aisle_count FROM aisles;

-- Department

SELECT COUNT(*) AS department_count FROM departments;

-- Products

SELECT COUNT(*) AS product_count FROM products;

-- Orders

SELECT COUNT(*) AS orders_count FROM orders;

-- JOIN PRODUCTS AND ORDERS
SELECT *
FROM aisles
WHERE PATINDEX('%[a-zA-Z]%', aisle_id) > 0;

-- Delete the rows where keys are mixed with strings
DELETE FROM products
WHERE PATINDEX('%[a-zA-Z]%', department_id) > 0 OR PATINDEX('%[a-zA-Z]%', aisle_id) > 0;

-- Alter table products
ALTER TABLE products ALTER COLUMN department_id INT;

-- Alter view curr_orders
ALTER VIEW curr_orders AS
(SELECT orders.order_id, user_id, products.product_id, order_number, order_dow, order_hour_of_day, days_since_prior_order, add_to_cart_order, product_name, aisle, department, reordered
FROM orders
INNER JOIN order_products__train ON orders.order_id = order_products__train.order_id
INNER JOIN products ON products.product_id = order_products__train.product_id
INNER JOIN departments ON departments.department_id = products.department_id
INNER JOIN aisles ON aisles.aisle_id = products.aisle_id);

-- Alter view prior_orders
ALTER VIEW prior_orders AS
(SELECT orders.order_id, user_id, products.product_id, order_number, order_dow, order_hour_of_day, days_since_prior_order, add_to_cart_order, product_name, aisle, department, reordered
FROM orders
INNER JOIN order_products__prior ON orders.order_id = order_products__prior.order_id
INNER JOIN products ON products.product_id = order_products__prior.product_id
INNER JOIN departments ON departments.department_id = products.department_id
INNER JOIN aisles ON aisles.aisle_id = products.aisle_id);

-- View null values
SELECT COUNT(*)
FROM orders
WHERE days_since_prior_order IS NULL;

-- Select top 5 rows from prior_orders where product_id is null
SELECT TOP 5 *
FROM prior_orders
WHERE product_id IS NULL;

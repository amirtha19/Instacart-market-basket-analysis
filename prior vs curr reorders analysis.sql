--- Prior vs Current

SELECT
      prod.product_id,
      prod.product_name,
      prod.aisle_id,
      prod.department_id,
      dept.department,
      aisles.aisle,
      SUM(op_prior.reordered) AS prior_reorders,
      SUM(op_curr.reordered) AS current_reorders
  FROM
      products AS prod
  JOIN
      prior_orders AS op_prior
      ON prod.product_id = op_prior.product_id
  JOIN
      curr_orders AS op_curr
      ON prod.product_id = op_curr.product_id
  JOIN
      departments AS dept
      ON prod.department_id = dept.department_id
  JOIN
      aisles AS aisles
      ON prod.aisle_id = aisles.aisle_id
  GROUP BY
      prod.product_id,
      prod.product_name,
      prod.aisle_id,
      prod.department_id,
      dept.department,
      aisles.aisle
  HAVING
      SUM(op_prior.reordered) < 10
      AND SUM(op_curr.reordered) >= 10
  ORDER BY
      current_reorders DESC;

----

--- Prior vs Current

with cte as (SELECT
      prod.product_id,
      prod.product_name,
      prod.aisle_id,
      prod.department_id,
      dept.department,
      aisles.aisle,
      SUM(op_prior.reordered) AS prior_reorders,
      SUM(op_curr.reordered) AS current_reorders
  FROM
      products AS prod
  JOIN
      prior_orders AS op_prior
      ON prod.product_id = op_prior.product_id
  JOIN
      curr_orders AS op_curr
      ON prod.product_id = op_curr.product_id
  JOIN
      departments AS dept
      ON prod.department_id = dept.department_id
  JOIN
      aisles AS aisles
      ON prod.aisle_id = aisles.aisle_id
  GROUP BY
      prod.product_id,
      prod.product_name,
      prod.aisle_id,
      prod.department_id,
      dept.department,
      aisles.aisle
  HAVING
      SUM(op_prior.reordered) >= 10
      AND SUM(op_curr.reordered) < 10
  ORDER BY
      prior_reorders DESC)

---

SELECT department,
COUNT(*) AS num_products
FROM cte
GROUP BY department
ORDER BY num_products DESC;

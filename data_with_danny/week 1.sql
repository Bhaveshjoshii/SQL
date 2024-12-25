Create database	dannys_diner;
use dannys_diner;

CREATE TABLE sales(
customer_id VARCHAR (1),
order_date DATE,
product_id INT
);

INSERT INTO sales
(customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


CREATE TABLE menu(
product_id INT,
product_name VARCHAR (5),
price INT
);

INSERT INTO menu
(product_id, product_name, price)
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

CREATE TABLE members(
customer_id VARCHAR(1),
joining_date DATE
);

INSERT INTO members
(customer_id, joining_date)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant?

SELECT
customer_id,
SUM(menu.price) AS total_sales
FROM sales
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT 
customer_id,
COUNT(DISTINCT order_date) AS visit_count
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH product AS
( SELECT
s.customer_id,
s.order_date,
m.product_name,
DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY order_date) AS details
FROM menu m
INNER JOIN sales s
ON m.product_id = s.product_id
GROUP By s.customer_id, S.order_date, m.product_name
)
SELECT
customer_id, product_name
FROM product
WHERE details = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
m.product_name,count(s.product_id)
FROM sales s 
INNER JOIN menu m
ON s.product_id =m.product_id
GROUP BY product_name
ORDER BY COUNT(s.customer_id) DESC



-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name, COUNT(product_name) AS times_purchased
FROM sales
LEFT JOIN menu 
  ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name
ORDER BY times_purchased DESC;
 
 
-- 6. Which item was purchased first by the customer after they became a member?

WITH joined_as_member AS (
  SELECT
    members.customer_id, 
    sales.product_id,
    ROW_NUMBER() OVER(
      PARTITION BY members.customer_id
      ORDER BY sales.order_date) AS row_num
  FROM dannys_diner.members
  JOIN dannys_diner.sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date > members.joining_date
)
SELECT 
  customer_id, 
  product_name 
FROM joined_as_member
JOIN dannys_diner.menu
  ON joined_as_member.product_id = menu.product_id
WHERE row_num = 1
ORDER BY customer_id ASC;


-- 7. Which item was purchased just before the customer became a member?

WITH before_member AS(
 SELECT
 sales.product_id,
 members.customer_id,
 ROW_NUMBER () OVER(
 PARTITION BY sales.customer_id 
 ORDER BY sales.order_date desc) AS row_num
FROM dannys_diner.sales
JOIN dannys_diner.members
ON sales.customer_id = members.customer_id
AND sales.order_date < members.joining_date
)
SELECT
customer_id,
product_name
FROM before_member
JOIN dannys_diner.menu
ON before_member.product_id = menu.product_id 
WHERE row_num = 1
ORDER BY customer_id ASC;



-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
	sales.customer_id,
    COUNT(sales.product_id) AS total_items,
    SUM(menu.price) AS total_sales
FROM dannys_diner.sales
INNER JOIN dannys_diner.members
 ON sales.customer_id = members.customer_id 
 AND sales.order_date < members.joining_date
INNER JOIN dannys_diner.menu
 ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;



-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_cte AS (
SELECT 
menu.product_id,
  CASE
   WHEN product_name = "sushi" THEN price * 20
   ELSE price * 10 END
   AS points
FROM menu
)
SELECT 
sales.customer_id, SUM(points_cte.points) AS total_points
FROM sales
INNER JOIN points_cte
	ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id;




	
	









CREATE SCHEMA pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;

CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;

CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  -- Cleaning Data
  
  -- Copying table to new table
  
drop table if exists customer_orders1;

create table customer_orders1 as
(select order_id, customer_id, pizza_id, exclusions, extras, order_time 
from customer_orders);

-- Cleaning data
update customer_orders1
set 
exclusions = case exclusions when 'null' then null else exclusions end,
extras = case extras when 'null' then null else extras end;

-- Copying table and cleaning data
drop table if exists runner_orders1;
create table runner_orders1 as 
(select order_id, runner_id, pickup_time,
case
 when distance like '%km' then trim('km' from distance)
 else distance 
end as distance,
case
 when duration like '%minutes' then trim('minutes' from duration)
 when duration like '%mins' then trim('mins' from duration)
 when duration like '%minute' then trim('minute' from duration)
 else duration
end as duration, cancellation 
from runner_orders);

-- cleaning data
update runner_orders1
set 
pickup_time = case pickup_time when 'null' then null else pickup_time end,
distance = case distance when 'null' then null else distance end,
duration = case duration when 'null' then null else duration end,
cancellation = case cancellation when 'null' then null else cancellation end;

-- update datatypes for runner table
 alter table runner_orders1
 modify column pickup_time datetime null,
 modify column distance decimal(5,1) null,
 modify column duration int null;
 

 
																	-- A. Pizza Metrics
                                                                    
-- 1.How many pizzas were ordered?

SELECT COUNT(order_id) FROM customer_orders

-- 2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) FROM customer_orders

-- 3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(order_id) AS order_delivered
FROM runner_orders1
WHERE distance is not null
group by runner_id;

-- 4.How many of each type of pizza was delivered?
SELECT pizza_names.pizza_name, count(customer_orders1.pizza_id) as TotalDelivered
FROM customer_orders1
INNER JOIN runner_orders1
ON customer_orders1.order_id = runner_orders1.order_id
INNER JOIN pizza_names
ON pizza_names.pizza_id = customer_orders1.pizza_id
WHERE runner_orders1.distance IS NOT NULL
GROUP BY  pizza_names.pizza_name;


-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_orders1.customer_id, pizza_names.pizza_name, COUNT(customer_orders1.pizza_id) as TotalPizzaOrdered
FROM customer_orders1
INNER JOIN pizza_names
ON customer_orders1.pizza_id = pizza_names.pizza_id 
GROUP BY customer_orders1.customer_id, pizza_names.pizza_name
ORDER BY customer_orders1.customer_id;


-- 6.What was the maximum number of pizzas delivered in a single order?

SELECT  order_id, COUNT(order_id) AS qty
FROM customer_orders1 
GROUP BY order_id
ORDER BY qty DESC
LIMIT 1;



-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    customer_orders1.customer_id,
    SUM(
        CASE 
            WHEN (exclusions IS NOT NULL AND exclusions != 0) OR (extras IS NOT NULL AND extras != 0) THEN 1
            ELSE 0
        END
    ) AS Atleastonechange,
    SUM(
        CASE
            WHEN (exclusions IS NULL OR exclusions = 0) AND (extras IS NULL OR extras = 0) THEN 1
            ELSE 0
        END
    ) AS Nochange 
FROM 
    customer_orders1
INNER JOIN 
    runner_orders1 ON runner_orders1.order_id = customer_orders1.order_id
WHERE 
    runner_orders1.distance != 0
GROUP BY 
    customer_orders1.customer_id;



-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT customer_orders1.customer_id,
SUM(
	CASE
		WHEN(exclusions IS NOT NULL AND exclusions != 0) AND  (extras IS NOT NULL AND extras != 0) THEN 1
        ELSE 0
        END)
        AS both_change_in_pizza
FROM customer_orders1
INNER JOIN 
    runner_orders1 ON runner_orders1.order_id = customer_orders1.order_id
WHERE 
    cancellation is NULL
GROUP BY 
    customer_orders1.customer_id;
ORDER BY 
	customer_orders1.customer_id;
		

-- 9.What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT(HOUR FROM order_time) AS Hourlydata, COUNT(order_id) AS totalpizzaordered
FROM customer_orders1
GROUP BY Hourlydata
ORDER BY Hourlydata;


-- 10.What was the volume of orders for each day of the week?

SELECT DAYNAME(order_time) AS DailyData, COUNT(order_id) AS TotalPizzaOrdered
FROM customer_orders1
GROUP BY Dailydata
ORDER BY TotalPizzaOrdered DESC;


                                                     -- B. Runner and Customer Experience
                                                     
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT week(registration_date) as 'Week_of_registration',
       count(runner_id) as 'Number of runners'
FROM pizza_runner.runners
GROUP BY Week_of_registration;



-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id,round(avg(timestampdiff(minute,order_time, pickup_time)),1) as AvgTime
from runner_orders1
inner join customer_orders1
on customer_orders1.order_id = runner_orders1.order_id
where distance != 0
group by runner_id
order by AvgTime;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?



-- 4. What was the average distance travelled for each customer?
-- 5. What was the difference between the longest and shortest delivery times for all orders?
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- 7. What is the successful delivery percentage for each runner?

  
-- ============================================================
-- Target Brazil E-commerce SQL Analysis
-- Submitted by: Aravinth Baskar
-- Source: Target SQL Business Case project
-- Platform used: Google BigQuery
-- This file contains the SQL queries used in the project.
-- ============================================================

-- ------------------------------------------------------------
-- Query 1 (1.1) : Data type of all columns in the "customers" table.
-- ------------------------------------------------------------
SELECT column_name, data_type
FROM scalar-dsml-sql-482016.Target.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = "customers";

-- ------------------------------------------------------------
-- Query 2 (1.2) : Time range between which the orders were placed.
-- ------------------------------------------------------------
SELECT MIN(order_purchase_timestamp) AS First_order_date,
       MAX(order_purchase_timestamp) AS Latest_order_date 
FROM `Target.orders`;

-- ------------------------------------------------------------
-- Query 3 (1.3) : Count the Cities & States of customers who ordered during the given period.
-- ------------------------------------------------------------
SELECT COUNT(DISTINCT c.customer_city) AS Total_Number_of_Cities,
       COUNT(DISTINCT c.customer_state) AS Total_Number_of_States 
FROM `Target.orders` o JOIN `Target.customers` c 
ON o.customer_id = c.customer_id;

-- ------------------------------------------------------------
-- Query 4 (2.1) : Is there a growing trend in the no. of orders placed over the past years?
-- ------------------------------------------------------------
SELECT FORMAT_DATE('%Y-%m', order_purchase_timestamp) AS Year_Month,
       COUNT(*) AS Orders_per_Month 
FROM `Target.orders` 
GROUP BY Year_Month 
ORDER BY Year_Month;

-- ------------------------------------------------------------
-- Query 5 (2.2) : Can we see some kind of monthly seasonality in terms of the no. of orders being placed?
-- ------------------------------------------------------------
SELECT EXTRACT(MONTH FROM order_purchase_timestamp) AS Month,
       COUNT(*) AS Orders_Monthwise
FROM `Target.orders` 
GROUP BY Month 
ORDER BY Month ASC;

-- ------------------------------------------------------------
-- Query 6 (2.3) : During what time of the day, do the Brazilian customers mostly place their orders? (Dawn, Morning, Afternoon or Night)
-- ------------------------------------------------------------
WITH Hour_Extract AS
(
SELECT EXTRACT(HOUR FROM order_purchase_timestamp) AS Hour_time
FROM `Target.orders`
)
SELECT CASE
       WHEN Hour_time BETWEEN 0 AND 6 THEN "Dawn"
       WHEN Hour_time BETWEEN 7 AND 12 THEN "Mornings"
       WHEN Hour_time BETWEEN 13 AND 18 THEN "Afternoon"
       WHEN Hour_time BETWEEN 19 AND 23 THEN "Night"
       END AS Day_period,
       COUNT(*) AS No_of_orders
FROM Hour_Extract
GROUP BY Day_period 
ORDER BY No_of_orders DESC;

-- ------------------------------------------------------------
-- Query 7 (3.1) : Get the month on month no. of orders placed in each state.
-- ------------------------------------------------------------
SELECT FORMAT_DATE("%Y-%m", o.order_purchase_timestamp) AS Year_Month,
       c.customer_state AS State,
       COUNT(*) AS No_of_orders 
FROM `Target.orders` o JOIN `Target.customers` c 
ON o.customer_id = c.customer_id 
GROUP BY Year_Month, State
ORDER BY State ASC, Year_Month ASC;

-- ------------------------------------------------------------
-- Query 8 (3.2) : How are the customers distributed across all the states?
-- ------------------------------------------------------------
SELECT customer_state AS State,
       COUNT(DISTINCT customer_id) AS No_of_Customers 
FROM `Target.customers` 
GROUP BY State
ORDER BY No_of_Customers DESC;

-- ------------------------------------------------------------
-- Query 9 (4.1) : Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only). You can use the "payment_value" column in the payments table to get the cost of orders.
-- ------------------------------------------------------------
WITH two_years AS 
(
SELECT order_id,
       EXTRACT(YEAR FROM order_purchase_timestamp) AS year
FROM `Target.orders`
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) IN (2017, 2018) AND
      EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8 
),
cost_per_year AS
(
SELECT t.year,
       SUM(p.payment_value) AS total_cost
FROM two_years t JOIN `Target.payments` p 
ON t.order_id = p.order_id 
GROUP BY t.year
)
SELECT year,
       ROUND(
             (total_cost - LAG(total_cost) OVER (ORDER BY year)) * 100.0
             /LAG(total_cost) OVER (ORDER BY year),2
			) AS pct_increase
FROM cost_per_year; 

-- ------------------------------------------------------------
-- Query 10 (4.2) : Calculate the Total & Average value of order price for each state.
-- ------------------------------------------------------------
WITH cte AS 
( 
SELECT c.customer_state AS State, 
       o.order_id AS o_id, 
       SUM(oi.price) AS Total_price 
FROM `Target.orders` o JOIN `Target.order_items` oi 
ON o.order_id = oi.order_id 
JOIN `Target.customers` c 
ON o.customer_id = c.customer_id 
GROUP BY c.customer_state, o.order_id 
) 
SELECT State, 
       ROUND(SUM(Total_price),2) AS Total_order_value, 
       ROUND(AVG(Total_price),2) AS Average_value 
FROM cte 
GROUP BY State 
ORDER BY State;

-- ------------------------------------------------------------
-- Query 11 (4.3) : Calculate the Total & Average value of order freight for each state
-- ------------------------------------------------------------
WITH cte AS 
(
 SELECT c.customer_state AS State, 
        o.order_id,
        SUM(oi.freight_value) AS freight_sum
FROM `Target.orders` o
JOIN `Target.order_items` oi
ON o.order_id = oi.order_id 
JOIN `Target.customers` c
ON o.customer_id = c.customer_id 
GROUP BY c.customer_state, o.order_id 
)
SELECT State,
       ROUND(SUM(freight_sum),2) AS Total_freight,
       ROUND(AVG(freight_sum),2) AS Avg_freight
FROM cte
GROUP BY State 
ORDER BY State;

-- ------------------------------------------------------------
-- Query 12 (5.1) : Find the no. of days taken to deliver each order from the order’s purchase date as delivery time. Also, calculate the difference (in days) between the estimated & actual delivery date of an order
-- ------------------------------------------------------------
SELECT order_id,
	   DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver,
       DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS diff_estimated_delivery
FROM `Target.orders`;

-- ------------------------------------------------------------
-- Query 13 (5.2) : Find out the top 5 states with the highest & lowest average freight value. 
-- ------------------------------------------------------------
WITH cte AS 
( 
SELECT c.customer_state AS State, 
       o.order_id, 
       SUM(oi.freight_value) AS freight_sum 
FROM `Target.orders` o JOIN `Target.order_items` oi 
ON o.order_id = oi.order_id 
JOIN `Target.customers` c 
ON o.customer_id = c.customer_id 
GROUP BY c.customer_state, o.order_id 
), 
Average_freight AS  
( 
SELECT State, 
       ROUND(AVG(freight_sum),2) AS Avg_freight 
FROM cte 
GROUP BY State 
), 
Average_Ranked AS 
( 
SELECT State, 
       Avg_freight, 
       DENSE_RANK() OVER (ORDER BY Avg_freight DESC) AS Toprank, 
       DENSE_RANK() OVER (ORDER BY Avg_freight ASC) AS Bottomrank 
FROM Average_freight 
) 
SELECT State, 
       Avg_freight  
FROM Average_Ranked 
WHERE Toprank <= 5  
OR Bottomrank <= 5 
ORDER BY Avg_freight ASC;

-- ------------------------------------------------------------
-- Query 14 (5.3) : Find out the top 5 states with the highest & lowest average delivery time.
-- ------------------------------------------------------------
WITH delivery_time AS 
(  
SELECT order_id, 
       customer_id, 
       DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) 
AS time_to_deliver 
FROM `Target.orders` 
WHERE order_delivered_customer_date IS NOT NULL 
), 
Average_time AS 
( 
SELECT c.customer_state AS State, 
       AVG(d.time_to_deliver) AS Avg_time_to_deliver 
FROM delivery_time d 
JOIN `Target.customers` c 
ON d.customer_id = c.customer_id 
GROUP BY c.customer_state 
), 
Ranked AS 
( 
SELECT State, 
       Avg_time_to_deliver, 
       DENSE_RANK() OVER (ORDER BY Avg_time_to_deliver ASC) Lowrank, 
       DENSE_RANK() OVER (ORDER BY Avg_time_to_deliver DESC) Highrank 
FROM Average_time 
) 
SELECT State, 
       ROUND(Avg_time_to_deliver,2) AS Avg_delivery_time 
FROM Ranked 
WHERE Lowrank <= 5 OR 
Highrank <= 5 
ORDER BY Avg_delivery_time ASC;

-- ------------------------------------------------------------
-- Query 15 (5.4) : Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state.
-- ------------------------------------------------------------
WITH Difference AS
(
SELECT order_id,
       customer_id, 
       DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS diff_estimated_delivery 
FROM `Target.orders`
WHERE order_delivered_customer_date IS NOT NULL
)
SELECT c.customer_state AS State, 
       ROUND(AVG(d.diff_estimated_delivery),2) AS Avg_diff_in_days
FROM Difference d 
JOIN `Target.customers` c
ON d.customer_id = c.customer_id
GROUP BY c.customer_state 
ORDER BY Avg_diff_in_days ASC 
LIMIT 5;

-- ------------------------------------------------------------
-- Query 16 (6.1) : Find the month on month no. of orders placed using different payment types.
-- ------------------------------------------------------------
SELECT FORMAT_DATE('%Y-%m',o.order_purchase_timestamp) AS Year_month,
       p.payment_type,
       COUNT(DISTINCT o.order_id) AS No_of_orders
FROM `Target.orders` o 
JOIN `Target.payments` p 
ON o.order_id = p.order_id 
GROUP BY Year_month, p.payment_type 
ORDER BY Year_month ASC, UPPER(p.payment_type) ASC;

-- ------------------------------------------------------------
-- Query 17 (6.2) : Find the no. of orders placed on the basis of the payment installments that have been paid
-- ------------------------------------------------------------
SELECT payment_installments,
       COUNT(DISTINCT order_id) AS No_of_orders 
FROM `Target.payments` 
WHERE payment_installments > 0 
GROUP BY payment_installments 
ORDER BY payment_installments;
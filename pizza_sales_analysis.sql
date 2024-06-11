create database pizza_sales;

use pizza_sales;


create table orders (
	order_id int primary key,
    date text,
    time text
)


select * from orders;

select * from order_details;

alter table order_details 
rename column order_details_id to order_details;


select* from pizza_types;

select* from orders;
select* from order_details;
select* from pizzas;
select * from pizza_types;


create view pizza_details as
select p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
from pizzas p 
join pizza_types pt 
on pt.pizza_type_id = p.pizza_type_id;

select * from pizza_details;


/* changing the data type of date and time column*/

alter table orders
modify date DATE;

alter table orders
modify time TIME;


/* no null values or missing values in this table*/

/* Data Analysis*/

-- total revenue
select round(sum(pizzas.price*order_details.quantity),2) as total_revenue 
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id;


-- total number of pizzas sold 
select sum(quantity) as total_pizzas_sold 
from order_details;

-- total orders
select count(distinct order_id) as total_orders
from order_details;

-- average order value 
select sum(od.quantity*p.price)/count(distinct(od.order_id)) as avg_order_value
from order_details od
join pizza_details p 
on od.pizza_id = p.pizza_id;


-- average number of pizza per order 
select sum(quantity)/count(distinct (order_id))  
from order_details;


-- total revenue and no. of orders per category 

select sum(od.quantity*p.price) as revenue , count(distinct order_id) as orders_per_category,pt.category
from order_details od
join pizzas p on od.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category;


-- hourly,daily and monthly trend in orders and revenue of pizza
SELECT 
    CASE          -- this all creates a new column meal_time based on these conditions 
        WHEN HOUR(o.time) BETWEEN 9 AND 11 THEN 'Late Morning'       /* evaluates hour part of the time column*/
        WHEN HOUR(o.time) BETWEEN 12 AND 14 THEN 'Lunch'
        WHEN HOUR(o.time) BETWEEN 15 AND 17 THEN 'Mid Afternoon'
        WHEN HOUR(o.time) BETWEEN 18 AND 20 THEN 'Dinner'
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN 'Late Night'
        ELSE 'Others'
    END AS meal_time, 
    COUNT(DISTINCT od.order_id) AS total_orders 
FROM order_details od 
JOIN orders o ON o.order_id = od.order_id
GROUP BY meal_time
order by total_orders desc;

-- weekdays

select DAYNAME(o.date) as day_name,count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id 
group by dayname(o.date)
order by total_orders desc;

-- monthly 

select MONTHNAME(o.date) as month_name,count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id 
group by monthname(o.date)
order by total_orders desc;


-- most ordered pizza

SELECT pt.name, order_counts.orders
FROM pizza_types pt
JOIN (
    SELECT p.pizza_type_id, COUNT(DISTINCT od.order_id) AS orders
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY p.pizza_type_id
    ORDER BY orders DESC
) AS order_counts ON pt.pizza_type_id = order_counts.pizza_type_id;


-- top 5 pizzas by revenue
select p.name,sum(od.quantity*p.price) as total_revenue
from order_details od
join pizza_details p
on od.pizza_id = p.pizza_id 
group by p.name
order by total_revenue desc
limit 5;


-- top used ingredients
-- creating seperate columns for distinct ingredients
CREATE TEMPORARY TABLE numbers AS (
    SELECT 1 AS n UNION ALL 
    SELECT 2 UNION ALL 
    SELECT 3 UNION ALL 
    SELECT 4 UNION ALL 
    SELECT 5 UNION ALL 
    SELECT 6 UNION ALL 
    SELECT 7 UNION ALL 
    SELECT 8 UNION ALL 
    SELECT 9 UNION ALL 
    SELECT 10
);

SELECT ingredient, COUNT(ingredient) AS ingredient_count
FROM (
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(pd.ingredients, ',', n.n), ',', -1) AS ingredient
    FROM order_details od
    JOIN pizza_details pd ON pd.pizza_id = od.pizza_id
    JOIN numbers n ON CHAR_LENGTH(pd.ingredients) - CHAR_LENGTH(REPLACE(pd.ingredients, ',', '')) >= n.n - 1
) AS subquery
GROUP BY ingredient
ORDER BY ingredient_count DESC;

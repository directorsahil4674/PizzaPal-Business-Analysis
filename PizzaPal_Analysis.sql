 use pizzahut; 
-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) as total_orders FROM orders; 

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM
    pizzas p
        INNER JOIN
    order_details o ON p.pizza_id = o.pizza_id; 

-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY 2 DESC
LIMIT 1; 
    
-- Identify the most common pizza size ordered.

SELECT 
    p.size, count(o.quantity) AS orders
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY 1
ORDER BY 2 DESC; 

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(o.quantity) AS orders
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5; 

-- Intermediate Sql Queries. 

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(o.quantity) AS total_quant
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY 1
ORDER BY 2 DESC; 

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) AS hours, COUNT(order_id) AS orders
FROM
    orders
GROUP BY 1; 

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY 1; 
-- Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(avg_orders), 2) AS average_value
FROM
    (SELECT 
        o.date AS day, SUM(od.quantity) AS avg_orders
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY 1) AS order_quantity;  
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name; 

SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS Revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3; 

-- Advance SqL

-- Calculate the percentage contribution of each pizza type to total revenue.

CREATE temporary TABLE total_sales as 
	SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id
                    ;
                    
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price)/ (SELECT total_sales from total_sales)* 100, 2) as revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY 1
ORDER BY 2 DESC; 

-- Analyze the cumulative revenue generated over time.

SELECT * FROM orders; 

SELECT 
	date, 
SUM(revenue) over (order by date) as cum_revenue 
from 
(SELECT orders.date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders 
on 
orders.order_id = order_details.order_id
group by orders.date) as sales; 

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue from 

(SELECT category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from 
(SELECT 
    pizza_types.category,
    pizza_types.name,
    ROUND(SUM((order_details.quantity) * pizzas.price), 2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1 , 2) as a) as b
where rn <= 3; 

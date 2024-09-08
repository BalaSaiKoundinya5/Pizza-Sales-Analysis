/* 1 Retrieve the total number of orders placed.*/


SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

/* 2 Calculate the total revenue generated from pizza sales.*/
SELECT SUM(price) AS Total_revenue FROM pizzas;
SELECT 
    ROUND(SUM(order_details.quantity*pizzas.price),2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

/* 3 Identify the highest-priced pizza.*/
SELECT 
    pizza_types.name, MAX(pizzas.price) AS max_price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY max_price DESC
LIMIT 1;

/* 4 Identify the most common pizza size ordered.*/
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS most_ordered
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY most_ordered DESC
LIMIT 1;

-- 5 List the top 5 most ordered pizza types
-- along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6 Join the necessary tables to find the total quantity of
-- each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;


-- 7 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.order_time) AS hour, COUNT(orders.order_id) AS order_count
FROM
    orders
GROUP BY HOUR(orders.order_time)
ORDER BY hour DESC;


-- 8 Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pizza_types.category, COUNT(pizza_types.name) AS Total_Count
FROM
    pizza_types
GROUP BY pizza_types.category 
ORDER BY Total_Count DESC;

-- 9 Group the orders by date and 
-- calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS Avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date AS Date,
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- 10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Total_Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Revenue DESC
LIMIT 3;

-- 11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS Total_Sales
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100 , 2) AS Total_Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Revenue DESC;

-- 12 Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(Total_Revenue) OVER(order by order_date) AS cumulative_evenue FROM 
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS Total_Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS Sales;

-- 13 Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.
SELECT name,revenue from 
(SELECT category,name,revenue,
rank() over (partition by category order by revenue desc) AS rnk 
FROM 
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM((order_details.quantity * pizzas.price)) AS Revenue
FROM
    pizza_types 
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) AS a) AS b
WHERE rnk <=3;




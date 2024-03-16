--PIZZA SALES SQL ANALYSIS


--Data To Work With
select * from pizza_sales



--KPIs

--Total Revenue
select SUM (total_price) AS Total_revenue from pizza_sales

--2)Average Order Value
select sum (total_price)/ count (distinct order_id) as Average_Order_Value from [pizza_sales]

--3)Total Pizza Sold
select sum(quantity)  as Total_Pizza_Sold from pizza_sales

--4)Total Orders
select count(distinct (order_id)) as Total_Orders from pizza_sales

--5)Avg Pizzas per order
SELECT CAST(CAST(sum(quantity) AS DECIMAL(10,3)) / 
CAST(count(distinct (order_id)) AS DECIMAL(10,3)) AS DECIMAL(10,3))
AS Avg_Pizzas_per_order
FROM pizza_sales



--CHART REQUIREMENTS

--1)Daily trend for total order
SELECT Datename (DW, order_date) AS Order_day,
       Count(distinct (order_id)) AS Total_Order
FROM pizza_sales
group by datename(DW, order_date)

--2)Monthly trend for total order
SELECT Datename (MONTH, order_date) AS Order_month,
       Count(distinct (order_id)) AS Total_Order
FROM pizza_sales
group by datename(MONTH, order_date)
ORDER BY Total_Order desc

--3)Percentage of sales by pizza category
SELECT pizza_category,
CAST(sum(total_price) AS decimal (10,2)) as total_revenue,
CAST(sum(total_price) * 100 / (SELECT sum(total_price) from pizza_sales) AS decimal (10,2)) AS percentage_by_category
FROM pizza_sales
group by pizza_category

--4)Percentage of sales by pizza size
SELECT pizza_size,
CAST(sum(total_price) AS decimal (10,2)) as total_revenue,
CAST(sum(total_price) * 100 / (SELECT sum(total_price) from pizza_sales) AS decimal (10,2)) AS percentage_by_size
FROM pizza_sales
group by pizza_size 
order by total_revenue

--5)Total Pizza Sold By Category
SELECT pizza_category,
sum(quantity) as total_quantity,
CAST(sum(quantity) * 100 / (SELECT sum(quantity) from pizza_sales) AS decimal (10,2)) AS percentage_by_unit_size
FROM pizza_sales
group by pizza_category
order by total_quantity

--6)Top 5 pizza places by revenue
select top 5 pizza_name, sum(total_price) as total_revenue from pizza_sales
group by pizza_name
order by Total_Revenue desc

--7)Bottom 5 pizza places by revenue
select top 5 pizza_name, sum(total_price) as total_revenue from pizza_sales
group by pizza_name
order by Total_Revenue 

--8)Top 5 pizza places by quantity
select top 5 pizza_name, SUM(quantity) as total_pizza_sold
from pizza_sales
group by pizza_name
order by total_pizza_sold desc

--9)Bottom 5 pizza places by quantity
select top 5 pizza_name, SUM(quantity) as total_pizza_sold
from pizza_sales
group by pizza_name
order by total_pizza_sold

--10)Top 5 Pizzas By Total Order 
select top 5 pizza_name, count(distinct (order_id)) as total_pizza_ordered
from pizza_sales
group by pizza_name
order by total_pizza_ordered desc

--11)Bottom 5 Pizzas By Total Order
select top 5 pizza_name, count(distinct (order_id)) as total_pizza_ordered
from pizza_sales
group by pizza_name
order by total_pizza_ordered

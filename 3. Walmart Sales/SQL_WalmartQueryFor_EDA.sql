--Data To Work With
select * from [WalmartDB]..[WalmartSalesData.csv]


----------------------------------------------------------------------
----------------------------------------------------------------------


--TEST BEFORE FEATURE ENGINEERING

-- Time of The Day
select time,
(case 
	when Time between '00:00:00' and '12:00:00' then 'Morning' 
	when Time between '12:00:01' and '4:00:00' then 'Afternoon'
	else 'Evening'
END)
as time_of_day
from [WalmartDB]..[WalmartSalesData.csv];
--Day Name
select date, datename(dw, Date)
as Day_Name
from [WalmartDB]..[WalmartSalesData.csv];
--Month Name
select date, datename(month, Date)
as Month_Name
from [WalmartDB]..[WalmartSalesData.csv];



----------------------------------------------------------------------
----------------------------------------------------------------------

-- Adding column into temporary table (FEATURE ENGINEERING)
DROP TABLE IF EXISTS #sales;
CREATE TABLE #sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(30) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct Float NOT NULL,
    total DECIMAL(12, 4) NOT NULL,   
	time TIME NOT NULL,
    time_of_day VARCHAR(30) NOT NULL,
	date DATETIME NOT NULL,
    Day_Name VARCHAR(30) NOT NULL,
    Month_Name VARCHAR(30) NOT NULL,
    payment VARCHAR(30) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct Float,
    gross_income DECIMAL(12, 4),
    rating Float
);

INSERT INTO #sales (
    invoice_id,
    branch,
    city,
    customer_type,
    gender,
    product_line,
    unit_price,
    quantity,
    tax_pct,
    total,
	time,
    time_of_day,
	date,
    Day_Name,
    Month_Name,
    payment,
    cogs,
    gross_margin_pct,
    gross_income,
    rating
)
SELECT 
    invoice_id,
    branch,
    city,
    customer_type,
    gender,
    product_line,
    unit_price,
    quantity,
    [Tax_5%],
    total,
	time,
    (CASE 
        WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning' 
        WHEN Time BETWEEN '12:00:01' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day,
	date,
    DATENAME(dw, date) AS Day_Name,
    DATENAME(month, Date) AS Month_Name,
    payment,
    cogs,
    gross_margin_percentage,
    gross_income,
    rating
FROM [WalmartDB]..[WalmartSalesData.csv];
--Above query executed updates all 1000 rows of data value

--Execute the above before executing any other query below,

--Showing Extra Features Of Time of the day, Day Name and Month Name in the table
select * from #sales


----------------------------------------------------------------------
----------------------------------------------------------------------

--Unique Cities
SELECT 
	DISTINCT city
FROM  [WalmartDB]..[WalmartSalesData.csv];

-- Branch In Each City
SELECT 
	city,
    branch
FROM [WalmartDB]..[WalmartSalesData.csv]
group by city, branch
order by city

----------------------------------------------------------------------
--------------------Product-------------------------------------------
----------------------------------------------------------------------

--Data To Work With
select * from #sales

--Unique Productlide The Data Have
select distinct Product_line from #sales

--Most Common Payment Method
SELECT payment, COUNT(quantity) AS usage_count
FROM #sales
GROUP BY payment
ORDER BY usage_count DESC;

--Most Popular Selling Product
SELECT Product_line, COUNT(quantity) AS sell_count
FROM #sales
GROUP BY Product_line
ORDER BY sell_count DESC;

--Revenue by Month
SELECT Month_Name, sum(total) AS revenue_count
FROM #sales
GROUP BY Month_Name
ORDER BY revenue_count DESC;

-- What Month had the Largest COGS?
SELECT Month_Name, MAX(cogs) AS cog_max
FROM #sales
GROUP BY Month_Name
ORDER BY cog_max DESC;

-- What Month had the Largest Total COGS?
SELECT Month_Name, sum(cogs) AS cog_sum
FROM #sales
GROUP BY Month_Name
ORDER BY cog_sum DESC;

-- What product line had the largest revenue?
SELECT product_line, sum(total) AS product_revenue_sum
FROM #sales
GROUP BY product_line
ORDER BY product_revenue_sum DESC;


-- What is the city with the largest revenue?
SELECT city, sum(total) AS city_revenue_sum
FROM #sales
GROUP BY city
ORDER BY city_revenue_sum DESC;

-- What product line had the largest VAT?
SELECT product_line, sum(tax_pct) AS tax_pct_sum
FROM #sales
GROUP BY product_line
ORDER BY tax_pct_sum DESC;


-- Fetching each product line showing "Good", "Bad". Good if its greater than average sales
with tar(total_average_revenue) as  (
select avg (total) from #sales)
select
	distinct s.product_line,t.total_average_revenue,
	avg (total) over (partition by s.product_line) as product_average_revenue,
	(case when avg (total) over (partition by s.product_line) >t.total_average_revenue then 'good'
	else 'bad'
	end) as evalution
from #sales as s
cross join tar as t;


-- Which branch sold more products than average product sold?
with sold(sold_average) as  (
select avg (quantity) from #sales)
select
	distinct s.product_line,so.sold_average,
	avg (quantity) over (partition by s.product_line) as product_average_revenue,
	(case when avg (total) over (partition by s.product_line) > so.sold_average then 'more/equal'
	else 'less'
	end) as evalution
from #sales as s
cross join sold as so


-- What is the most common product line by gender
SELECT product_line,gender, count(gender) AS gender_count
FROM #sales
GROUP BY product_line, gender 
ORDER BY gender_count DESC;

-- What is the average rating of each product line
SELECT product_line, avg(rating) AS Avg_ratting
FROM #sales
GROUP BY product_line 
ORDER BY Avg_ratting DESC;


---------------------------------------------------------------------
---------------------------- Customers ------------------------------
---------------------------------------------------------------------
--Data To Work With
select * from #sales

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM #sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM #sales;


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM #sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    sum(quantity)as total_amt_bought
FROM #sales
GROUP BY customer_type
order by total_amt_bought desc;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_count
FROM #sales
GROUP BY gender
ORDER BY gender_count desc;

-- What is the gender distribution per branch?
SELECT
	 branch, gender,
	COUNT(*) as gender_cnt
FROM #sales
GROUP BY branch,gender
ORDER BY branch, gender_cnt DESC;

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM #sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT
	branch, time_of_day,
	AVG(rating) AS avg_rating
FROM #sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM #sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
(SELECT aar.branch, aar.day_name , mar.max_average_rating 
FROM 
(
select 
	branch, day_name, avg(rating)  as all_average_rating  
from #sales group by branch,day_name
) as aar  JOIN 

(SELECT 
    branch,
    MAX(all_average_rating) AS max_average_rating
FROM 
    (select 
	branch, day_name, avg(rating)  as all_average_rating  
from #sales group by branch,day_name) as temp

group by branch) as mar
ON aar.branch = mar.branch
WHERE aar.all_average_rating = mar.max_average_rating )


----------------------------------------------------------------------
-------------------- Sales -------------------------------------------
----------------------------------------------------------------------

-- Number of sales made in each time of the day
SELECT
	time_of_day, day_name,
	COUNT(*) AS total_sales
FROM #sales
GROUP BY  Day_Name, time_of_day 
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM #sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM #sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM #sales
GROUP BY customer_type
ORDER BY total_tax;

----------------------------------------------------------------------
--------------END-----------------------------------------------------
----------------------------------------------------------------------








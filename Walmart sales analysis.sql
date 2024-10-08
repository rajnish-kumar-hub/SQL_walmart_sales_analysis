-- Create Database
CREATE DATABASE IF NOT EXISTS salesDataWalmart;


-- Create Table
CREATE TABLE sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL (10,2),
quantity INT NOT NULL,
VAT FLOAT (6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL (10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12,4) NOT NULL,
rating FLOAT(2,1)
);

-- Data cleaning
SELECT 
    *
FROM
    sales;
    
-- Add the time_of_day column
SELECT
	time,
    (CASE
		WHEN `time` BETWEEN  '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN  '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
    ) AS time_of_date
FROM sales;

ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
CASE
		WHEN `time` BETWEEN  '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN  '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);

-- Add day_name column

SELECT date, DAYNAME(date)
FROM sales;

ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column

SELECT date, MONTHNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------

-- How many unique cities does that data have?
	SELECT 
		DISTINCT city 
    FROM sales;
    
-- In which city is each branch?
SELECT 
	DISTINCT city, branch
FROM sales;

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT 
	DISTINCT product_line
FROM sales;

-- What is the most common payment method?
SELECT payment_method,COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most common selling product line?
SELECT product_line, COUNT(product_line) AS most_selling
FROM sales
GROUP BY product_line
ORDER BY most_selling DESC;

-- What is the total revenue by month?
SELECT 
	month_name AS month, 
	ROUND(SUM(total),2) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	 month_name AS month, 
	SUM(cogs) AS largest_cogs
FROM sales
GROUP BY month_name
ORDER BY largest_cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,
	SUM(total) AS product_line_revenue
FROM sales
GROUP BY product_line
ORDER BY product_line_revenue DESC;

-- What is the city with the largest revenue?
SELECT city,
	SUM(total) AS city_revenue
FROM sales
GROUP BY city
ORDER BY city_revenue DESC;

-- What product line had the largest vat?
SELECT product_line,
	AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT 
	product_line,
    gender,
	COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;
    
-- What is the average rating of each product line?
SELECT 
	product_line,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- -------------------------- Sales -------------------------------
-- --------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday?
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT 
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/VAT (Value Added Tax)?
SELECT 
	city,
    AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT 
	customer_type,
    AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT 
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT 
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT 
	customer_type,
	COUNT(customer_type) AS cnt_customer_type
FROM sales
GROUP BY customer_type
ORDER BY cnt_customer_type DESC;

-- Which customer type buys the most?
SELECT 
	customer_type,
    SUM(quantity) AS qty
FROM sales
GROUP BY customer_type
ORDER BY qty DESC;

-- What is the gender of most of the customer?
SELECT 
	gender,
    COUNT(gender) AS cnt_gender
FROM sales
GROUP BY gender
ORDER BY cnt_gender DESC;

-- What is the gender distribution per branch?
SELECT 
	branch,
    COUNT(gender) AS cnt_gender
FROM sales
GROUP BY branch
ORDER BY cnt_gender DESC;

-- Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
    AVG(rating) AS rating
FROM sales
GROUP BY time_of_day
ORDER BY rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
	time_of_day,
    AVG(rating) AS rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY rating DESC;

-- which day of the week has the best avg ratings?
SELECT 
	day_name,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- --------------------------------------------------------------------
-- --------------------- Revenue & Profit Calculations ----------------
-- --------------------------------------------------------------------

-- COST OF GOOD SOLD
SELECT unit_price,
	quantity,
    (unit_price * quantity) AS cogs
FROM sales;

-- VAT
SELECT cogs,
	cogs*0.05 AS VAT
FROM sales;

-- Total (gross_sales)
SELECT VAT,
	cogs,
    SUM(VAT + cogs) AS total
FROM sales
GROUP BY VAT,cogs;

-- grossProfit (grossIncome)
SELECT total,
	cogs,
    (total - cogs) AS grossIncome
FROM sales
GROUP BY total,cogs;

-- Gross Margin
SELECT 
    gross_income, 
    total, 
    (gross_income / total) * 100 AS gross_margin_pct
FROM 
    sales;





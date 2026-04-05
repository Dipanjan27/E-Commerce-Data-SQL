use e_commerce;
set sql_safe_updates = 0;

-- database e_commerce is having 4 tables customers, orderdetails, orders & products

-- We are analyzing all the tables by describing their contents.
-- Task: Describe the Tables:
-- Customers
-- Products
-- Orders
-- OrderDetails
describe customers;
describe products;
describe orders;
describe orderdetails;

-- We are identifying the top 3 cities with the highest number of customers 
-- to determine key markets for targeted marketing and logistic optimization.
select 
    location,
    count(customer_id) as number_of_customers
from customers
group by 1
order by 2 desc
limit 3 ;

-- ### INFERENCE ###
-- cities must be focused as a part of marketing strategies?
-- Delhi, Chennai, Jaipur

-- we are trying to determine how many customers fall into each order frequency category 
-- based on the number of orders they have placed.

with countcte as
(
select
    customer_id,
    count(order_id) as numberoforders
from orders
group by 1
order by 2 asc)
select
    numberoforders,
    count(customer_id) as customercount
from countcte
group by 1
order by 1 asc;

-- ### Engagement Depth Analysis ###
-- As the number of orders increases, the customer count decreases
-- Which customers category does the company experiences the most? -- OCCASIONAL SHOPPERS

-- Identifying products where the average purchase quantity per order is 2 but with a high total revenue 
-- suggesting premium product trends.

select 
    product_id,
    avg(quantity) avgquantity,
    sum(quantity*price_per_unit) as totalrevenue
from orderdetails
group by 1
having avgquantity =2
order by 2 desc, 3 desc;

-- ### INFERENCE###
-- Among products with an average purchase quantity of two, Product 1 ones exhibit the highest total revenue followed by Product 8

-- For each product category, we are calculating the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.
select
    p.category,
    count(distinct(o.customer_id)) as unique_customers
from orders as o 
join orderdetails as od on
o.order_id=od.order_id
join products as p on
od.product_id= p.product_id
group by 1
order by 2 desc;

-- ### INFERENCE ###
-- Electronics product category needs more focus as it is in high demand among the customers

-- Analyzing the month-on-month percentage change in total sales to identify growth trends.

with salescte as (
    select 
    date_format(order_date, '%Y-%m') as Month,
    sum(total_amount) as TotalSales,
    lag(sum(total_amount)) over(
        order by date_format(order_date, '%Y-%m')
    ) as pms
from orders
group by 1
order by 1 asc
)
select
    month,
    TotalSales,
    round((TotalSales-pms)/pms*100,2) as Percentchange
from salescte
group by month;

-- ### Sales Trend Analysis ###
-- During the month of Feb2024 , the sales experience the largest decline
-- Also July2023 showed the highest growth of sales
-- However there is no clear trend so the sales and it is fluctuating every month


-- Examining how the average order value changes month-on-month. 
-- Insights can guide pricing and promotional strategies to enhance order value.

with ordercte as(
select 
    date_format(order_date, '%Y-%m') as Month,
    round(avg(total_amount),2) as AvgOrderValue,
    round(lag(avg(total_amount)) over(
        order by date_format(order_date, '%Y-%m')
    ),2) as pmv
from orders
group by 1
)
select
    month,
    AvgOrderValue,
    AvgOrderValue-pmv as ChangeInValue
from ordercte
group by 1
order by 3 desc;

-- ### INFERENCE ###
-- December month has the highest change in the average order value


-- Based on sales data, identify products with the fastest turnover rates
-- suggesting high demand and the need for frequent restocking.
select 
    product_id,
    count(order_id) as SalesFrequency
from OrderDetails
group by 1
order by 2 desc
limit 5;

-- ###INFERENCE###
-- product_id 7 has the highest turnover rates and needs to be restocked frequently followed by product_id 3 and 4



-- Products purchased by less than 40% of the customer base 
-- indicating potential mismatches between inventory and customer interest.

select
    p.product_id,
    p.name,
    count(distinct(o.customer_id)) as UniqueCustomerCount
from products as p 
join orderdetails as od on
p.product_id=od.product_id
join orders as o on
od.order_id = o.order_id
join customers as c on
o.customer_id = c.customer_id
group by 1,2
having count(distinct(o.customer_id))<((select count(*) from customers)/100*40);

-- ### INFERENCE ###
-- Why might certain products have purchase rates below 40% of the total customer base? -- May be due to poor visibility on platform or pricing
-- What could be a strategic action to improve the sales of these underperforming products? -- Implement target marketing campaign to raise awareness and interest and also check competitive pricing


-- Evaluating the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
with firstcte as 
(
    select 
    customer_id,
    min(order_date) as first
from orders
group by 1
order by 1
)
select
    date_format(first, '%Y-%m') as FirstPurchaseMonth,
    count(customer_id) as TotalNewCustomers
from firstcte
group by 1
order by 1;

-- ### GROWTH-RATE TREND ###
-- the platform is showing a downward trend which implies the marketing campaigns are not much effective



-- Identifying the months with the highest sales volume 
-- aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods

select
    date_format(order_date, '%Y-%m') as Month,
    sum(total_amount) as TotalSales
from orders
group by 1
order by 2 desc
limit 3;

-- ### INFERENCE ###
-- September and December months will require major restocking of product and increased staffs
-- This may be due to the festive season during this time












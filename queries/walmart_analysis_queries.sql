-- Walmart sales analysis
select *
from walmart_clean;
-- 1)Size of dataset determination 
select count(*) as total_rows
from walmart_clean;

-- 2) Unique constumers 

select count(distinct user_id) as unique_customer
from walmart_clean;

-- 3) Product category distribution 

select distinct product_category
from walmart_clean
order by product_category;

-- 4) Spread age group 

select distinct age as age_group
from walmart_clean
order by 1 ;


-- 5) gender wise count of orders

select gender , count(*) as total_orders
from walmart_clean
group by gender;

-- 6) Sales by city 
select city_category,
count(*) as total_orders,
sum(purchase_amount) as total_sales
from walmart_clean
group by city_category
order by total_sales desc;

-- Customer segmentation hai abb 

-- 1) Average purchase by age group
select age ,
round(avg(purchase_amount),2) as avg_purchase ,
count(*) as total_orders
from walmart_clean
group by age
order by avg_purchase desc;

-- 2) Average spend gender wise 
select gender ,
round(avg(purchase_amount),2) as avg_purchase ,
count(*) as total_orders
from walmart_clean
group by gender
order by avg_purchase desc;

-- 3) Average spend basis of marital status + city category

select city_category ,
marital_status,
round(avg(purchase_amount),2) as avg_purchase ,
count(*) as total_orders
from walmart_clean
group by city_category , marital_status
order by city_category , marital_status desc;

-- 3) Based on custom age brackets
select age,
case 
 when age = '0-17' then 'Teen'
 when age in ('18-25','26-35') then 'Young Adult'
 when age in ('36-45','46-50') then 'Middle aged'
 when age in ('51-55') then 'Senior'
 else 'Retired'
end as age_segment,
 
round(avg(purchase_amount),2) as avg_spend ,
count(*) as total_orders
from walmart_clean
group by age , age_segment
order by avg_spend desc;




-- 1) Top 5 highest spending customers
with customer_spending as (
select user_id ,
sum(purchase_amount) as total_sales,
rank() over(order by sum(purchase_amount) desc) as spending_rank
from walmart_clean
group by user_id
)
select *
from customer_spending
where spending_rank <= 5;

-- 2) Repeat Buyers(3 or more times)
with customer_orders as (
select 
user_id,
purchase_amount,
row_number() over (partition by user_id order by purchase_amount desc) as order_number
from walmart_clean
)
select 
count(*) as total_useful_customers
from customer_orders 
where order_number >= 3;


-- 3) Revenue contribution by age group
with age_revenue as (
select 
age,
sum(purchase_amount) as age_sales,
sum(sum(purchase_amount)) over () as total_sales
from walmart_clean
group by age
)
select age,
age_sales,
round(age_sales *100 / total_sales ,2) as percentage_contribution
from age_revenue
order by percentage_contribution desc;


-- 4) Ranking of customer spend using city category
with city_customer_ranking as (
select 
city_category,
user_id,
sum(purchase_amount) as total_spent,
rank () over(partition by city_category order by sum(purchase_amount) desc) as city_rank
from walmart_clean
group by city_category,user_id
)
select*
from city_customer_ranking
where city_rank <= 3
order by city_category, city_rank;

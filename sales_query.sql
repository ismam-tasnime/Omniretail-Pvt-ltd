select * from public.sales_data_clean

-- 1. Which region has the highest total revenue?
create view highest_revenue_region as
select
distinct region,
round(sum(total_sale_amount)::numeric,2) as revenue
from public.sales_data_clean
group by 1
order by 2 desc
select * from public.highest_revenue_region

-- 2. Which product category generates the highest revenue on average per sale?
create view product_category_highest_rev_avg as
with cte1 as 
(select
product_category,
count(sale_date) as total_sales, 
sum(quantity_sold) as total_quantity,
round(sum(total_sale_amount)::numeric,2) as total_revenue
from public.sales_data_clean
group by 1)
select
product_category,
round(total_revenue/total_sales,2) as AOV
from cte1
order by 2 desc

-- 3. What is the return rate per product category?
create view return_rate_category as
with cte1 as
(select 
product_category,
count(sale_date)::numeric as total_orders,
count (case when returned='Yes' then sale_date else null end) as total_returned
from public.sales_data_clean
group by 1)
select
*,
round((total_returned/total_orders)*100,2) as return_rate
from cte1


-- 4. Identify the top 5 products with the highest total sales by quantity.
create view top_five as
select
product_id,
sum(quantity_sold) as total_quantity_sold
from public.sales_data_clean
group by 1
order by 2 desc
limit 5


-- 5. Which store has the lowest revenue but highest number of sales?
create view store_lowrev_highsale as
select
store_id,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
count(sale_id) as sales
from public.sales_data_clean
group by 1
order by 2 asc, 3 desc
limit 1

-- 6. How do different payment methods impact total revenue?
create view payment_method_impact as
with cte1 as 
(select 
payment_method,
round(sum(total_sale_amount)::numeric,2) as revenue,
(select sum(total_sale_amount)::numeric from public.sales_data_clean) as total_revenue 
from public.sales_data_clean
group by 1
order by 2 desc
)
select
*,
round((revenue/total_revenue)*100,2) as revenue_percentage
from cte1

-- 7). Which customers have made the most purchases in terms of total amount spent?
create view customer_highestspent as
select 
customer_id,
round(sum(total_sale_amount)::numeric,2) as total_amount_spent
from public.sales_data_clean
group by 1
order by 2 desc

-- 8. Which quarter sees the highest sales?
create view sales_analysis_quaterly as
select 
concat('Q',extract(quarter from sale_date::date)) as quarter,
ROUND(sum(total_sale_amount)::NUMERIC,2) as revenue
from public.sales_data_clean
group by 1
order by 1 asc

-- 9. What is the average unit price per product category?
create view avg_unit_price_category as
SELECT 
product_category,
ROUND(AVG (unit_price)::NUMERIC,2)
FROM public.sales_data_clean
group by 1


-- adhoc analytics
-- 1)total revenue
create view total_revenue as
select
round(sum(total_sale_amount)::numeric,2) as total_revenue
from public.sales_data_clean

-- 2) total quantity sold
create view total_quantity_sold as
select 
sum(quantity_sold) as total_quantity_sold
from public.sales_data_clean


-- 3) overall return rate 
create view overall_return_rate as
with cte1 as
(select 
count(sale_id)::numeric as total_orders,
count (case when returned='Yes' then sale_date else null end) as total_returned
from public.sales_data_clean
)
select
*,
round((total_returned/total_orders)*100,2) as return_rate
from cte1

-- 4) returned sales value  percentage
create view returned_sales_value_percentage as
with cte1 as (select 
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
)
select
*,
round((returned_sales_value/total_revenue)*100,2)
from cte1


-- 5)returned revenue rate by category

create view category_returned_revenue_rate as
with cte1 as(
select 
product_category,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1
)
select
*,
round((returned_sales_value/total_revenue)*100,2) return_rate
from cte1
order by round((returned_sales_value/total_revenue)*100,2) desc

-- 6) store analysis
create view stor_analysis as
with cte1 as(select
store_id,
count(sale_id) as total_order,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(round(sum(total_sale_amount)::numeric,2)/count(sale_id),2)  as revenur_per_order,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1
)
select
*,
round((returned_sales_value/total_revenue)*100,2) return_rate
from cte1
order by total_order desc

-- 7)region analysis

create view region_analysis as
with cte1 as(select
region,
count(sale_id) as total_order,
sum(quantity_sold),
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(round(sum(total_sale_amount)::numeric,2)/count(sale_id),2)  as revenur_per_order,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1
)
select
*,
round((returned_sales_value/total_revenue)*100,2) return_rate
from cte1
order by total_order desc



-- 8) monthly sales trend

create view monthly_sales as
with cte1 as(select
extract(month from sale_date::date),
to_char(sale_date::date,'month')as month,
count(sale_id) as total_order,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(round(sum(total_sale_amount)::numeric,2)/count(sale_id),2)  as revenur_per_order,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1,2
)
select
*,
round((returned_sales_value/total_revenue)*100,2) return_rate
from cte1
order by 1 asc




-- 9)product risk analysis

create view product_risk as
with cte1 as(select
product_id,
count(sale_id) as total_order,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(round(sum(total_sale_amount)::numeric,2)/count(sale_id),2)  as revenur_per_order,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1
),
cte2 as
(select
*,
round((returned_sales_value/total_revenue)*100,2) return_rate
from cte1
order by 1 asc
)
select 
*,
dense_rank() over(order by return_rate asc) as risk_rank
from cte2





-- 10_)customer analysis
create view customer_analysis as
with cte1 as(select
customer_id,
count(sale_id) as total_order,
round(sum(total_sale_amount)::numeric,2) as total_revenue,
round(round(sum(total_sale_amount)::numeric,2)/count(sale_id),2)  as revenur_per_order,
round(sum(case when returned='Yes' then total_sale_amount::numeric else null end),2) as returned_sales_value
from public.sales_data_clean
group by 1
)
select
*,
round((returned_sales_value/total_revenue)*100,2) as return_rate
from cte1
order by total_order desc










create database retail_project ;
use retail_project ;

create table customers (
customer_id varchar(20) primary key,
customer_name varchar(100),
segment varchar(50),
country varchar(50),
city varchar(50),
state varchar(50),
region varchar(50)
);
show tables;
DESCRIBE customers;

create table products (
product_id varchar(30) primary key,
category varchar (50),
sub_category varchar(50),
product_name varchar(200)
);
show tables;
DESCRIBE products;

create table orders (
order_id varchar (20) primary key,
customer_id varchar(20),
order_date date,
ship_date date,
ship_mode varchar(30),
Foreign key (customer_id) REFERENCES customers(customer_id)
);

SHOW TABLES;
DESCRIBE orders;

create table order_details (
order_line_id int auto_increment primary key,
order_id varchar(20),
product_id varchar (30),
sales decimal (10,2),
quantity int,
discount decimal (4,2),
profit decimal (10,2),
foreign key (order_id) references orders (order_id),
foreign key (product_id) references products(product_id)
);

SHOW TABLES;
DESCRIBE order_details;


CREATE TABLE staging_superstore (
    row_id INT,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(30),
    category VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(200),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2)
);

SELECT COUNT(*) FROM staging_superstore;

SELECT * FROM staging_superstore LIMIT 10;

INSERT INTO customers (customer_id, customer_name, segment, country, city, state, region)
SELECT customer_id, 
       MAX(customer_name) AS customer_name,
       MAX(segment) AS segment,
       MAX(country) AS country,
       MAX(city) AS city,
       MAX(state) AS state,
       MAX(region) AS region
FROM staging_superstore
GROUP BY customer_id;

SELECT COUNT(*) FROM customers;

TRUNCATE TABLE products;

INSERT INTO products (product_id, category, sub_category, product_name)
SELECT product_id,
       MAX(category) AS category,
       MAX(sub_category) AS sub_category,
       MAX(product_name) AS product_name
FROM staging_superstore
GROUP BY product_id;

SELECT COUNT(*) FROM products;

TRUNCATE TABLE orders;

INSERT INTO orders (order_id, customer_id, order_date, ship_date, ship_mode)
SELECT order_id,
       MAX(customer_id) AS customer_id,
       MAX(order_date) AS order_date,
       MAX(ship_date) AS ship_date,
       MAX(ship_mode) AS ship_mode
FROM staging_superstore
GROUP BY order_id;

SELECT COUNT(*) FROM orders;

TRUNCATE TABLE order_details;

INSERT INTO order_details (order_id, product_id, sales, quantity, discount, profit)
SELECT order_id, product_id, sales, quantity, discount, profit
FROM staging_superstore;

SELECT COUNT(*) FROM order_details;

- - analysis Quries

Monthly revenue trend

select DATE_FORMAT (O.order_date, '%Y-%m') AS order_month,
round(sum(od.sales), 2) AS total_revenue
 from orders o
 Join order_details od ON o.order_id = od.order_id
 group by Date_format(o.order_date,'%Y-%m')
 order by order_month ;
 
 Top 10 products by profit

select p.product_name, round(sum(od.profit),2) as total_profit
from products p join order_details od on p.product_id = od.product_id
group by p.product_name order by total_profit DESC limit 10

## Profit margin by category and region

select p.category, c.region ,
ROUND(SUM(od.sales),2) as total_sales,
ROUND(SUM(od.profit),2) as total_profit,
ROUND(SUM(od.profit) / SUM(od.sales) *100,2) as profit_margin_pct
from order_details od 
join products p on od.product_id = p.product_id 
join orders o on od.order_id = o.order_id
join customers c on o.customer_id = c.customer_id 
group by p.category, c.region
order by profit_margin_pct DESC ;

Discount vs Profit relationship

select p.category,
ROUND(AVG(od.discount)*100,2) As avg_discount_pct,
ROUND(AVG(od.profit),2) AS avg_profit,
ROUND(SUM(od.profit),2) AS total_profit
from order_details od 
join products p on od.product_id = p.product_id
group by p.category 
order by avg_discount_pct DESC; 


RFM Customer Segmentation (Recency, Frequency, Monetary)

select c.customer_id, c.customer_name,
DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(o.order_date)) AS recency_days,
COUNT(distinct o.order_id) as frequency,
ROUND(sum(od.sales),2) as monetary 
from customers c 
Join orders o on c.customer_id = o.customer_id
Join order_details od on o.order_id = od.order_id
group by c.customer_id, customer_name;

Score customers 1–5 on each metric using NTILE()

WITH rfm_raw AS (
select 
c.customer_id,
c.customer_name,
DATEDIFF((Select MAX(order_date) from orders),MAX(o.order_date)) AS recency_days,
count(DISTINCT O.order_id) As frequency,
Round(sum(od.sales),2) AS monetary
from customers c 
join orders o on c.customer_id=o.customer_id
join order_details od on od.order_id=o.order_id
group by c.customer_id, c.customer_name
),
rfm_scored As(
select customer_id,customer_name,recency_days,frequency,monetary,
NTILE(5) OVER (order by recency_days DESC) as r_score,
NTILE(5) OVER (order by frequency ASC) As f_score,
NTILE(5) OVER (order by monetary ASC) As m_score 
from rfm_raw 
)
select customer_id,
customer_name,
r_score,f_score,m_score,
(r_score + f_score + m_score) AS rfm_total,
CASE
When r_score >=4 AND f_score >=4 AND m_score >= 4 THEN 'Best Customers'
when r_score >=4 AND f_score >=2 THEN 'New Customers'
when r_score <=2 AND f_score >=4 THEN 'At Risk(was Loyal)'
when r_score <=2 AND f_score <=2 THEN 'Lost/Churned'
else'Regular'
end as segment
from rfm_scored ;

select o.customer_id,o.order_id,o.order_date
from orders o

ALTER USER 'root'@'localhost' REQUIRE NONE;

FLUSH PRIVILEGES;



# 🍽️ Danny's Diner - SQL Challenge

The source of this information is from [Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)

# Table of Contents
- [Introduction](#introduction)
- [Problem Statement](#problem-statement)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Example Datasets](#example-datasets)
- [Table Creation and Information](#table-creation-and-information)
- [Case Study Answers](#case-study-answers)

# Introduction 
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.
Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

# Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study: `sales`, `menu` and `members`.
You can inspect the entity relationship diagram and example data below.

# Entity Relationship Diagram
![image](https://github.com/shrek-28/Danny-Diner-Challenge/assets/122817076/f3055370-c42a-44d2-89cf-11f992588afc)

# Example Datasets
All datasets exist within the `dannys_diner` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

**Table 1: sales**
The `sales` table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

**Table 2: menu**
The `menu` table maps the `product_id` to the actual `product_name` and `price` of each menu item.

**Table 3: members**
The final `members` table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

# Table Creation and Information

1. For Sales Table:
````sql
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

SELECT * FROM SALES
````
Result: 

| customer_id | order_date | product_id |
| ---- | ---- | ---- |
| A | 2021-01-01 | 1 |
| A | 2021-01-01 | 2 |
| A | 2021-01-07 | 2 |
| A | 2021-01-10 | 3 |
| A | 2021-01-11 | 3 |
| A | 2021-01-11 | 3 |
| B | 2021-01-01 | 2 |
| B | 2021-01-02 | 2 |
| B | 2021-01-04 | 1 |
| B | 2021-01-11 | 1 |
| B | 2021-01-16 | 3 |
| B | 2021-02-01 | 3 |
| C | 2021-01-01 | 3 |
| C | 2021-01-01 | 3 |
| C | 2021-01-07 | 3 |

2. Menu Table
````sql
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
````
Result:

| product_id | product_name | price |
| 1 | sushi | 10 |
| 2 | curry | 15 |
| 3 | ramen | 12 |

3. Members Table
````sql
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
````
Result:

| customer_id | join_date |
| A | 2021-01-07 |
| B | 2021-01-09 |

# Case Study Answers

1. What is the total amount each customer spent at the restaurant?
Query:
````sql
SELECT sales.customer_id, SUM(menu.price) as total_sales
from sales
inner join menu on sales.product_id = menu.product_id
group by sales.customer_id;
````
Result:

| customer_id | total_sales |
|--- |--- |
| A | 76 |
| B | 74 |
| C | 36 |

2. How many days has each customer visited the restaurant?
Query:
````sql
SELECT sales.customer_id, count(distinct order_date) from sales
group by sales.customer_id;
````
Result:
|customer_id| count |
| --- |--- |
| A | 4 |
| B | 6 |
| C | 2 |

3. What was the first item from the menu purchased by each customer?
Query:
````sql
WITH order_info_cte AS
  (SELECT customer_id,
          order_date,
          product_name,
          DENSE_RANK() OVER(PARTITION BY s.customer_id
                            ORDER BY s.order_date) AS rank_num
   FROM sales AS s
   JOIN menu AS m ON s.product_id = m.product_id)
SELECT customer_id,
       product_name
FROM order_info_cte
WHERE rank_num = 1
GROUP BY customer_id,
         product_name;
````
Result:

| customer_id | product_name |
| --- | --- |
| A | curry |
| A | sushi |
| B | curry |
| C | ramen |

5. What is the most purchased item on the menu and how many times was it purchased by all customers?
Query:
````sql
with id1 as
(with sale_count as (SELECT sales.product_id as prod_id, count(*) as prod_count from sales group by sales.product_id order by prod_count desc)
select prod_id from sale_count where (prod_count = (select max(prod_count) from sale_count)))
SELECT sales.customer_id, COUNT(*) AS purchase_count
FROM sales
JOIN id1 ON sales.product_id = id1.prod_id
GROUP BY sales.customer_id;
````
Result:

| customer_id | purchase_count |
| A | 3 |
| B | 2 |
| C | 3 |

7. Which item was the most popular for each customer?
Query:
````sql
with order_menu as (
SELECT product_name,
          customer_id,
          count(product_name) AS order_count,
		  rank() over(PARTITION BY customer_id
                      ORDER BY count(product_name) DESC) AS rank_num
   FROM menu
   INNER JOIN sales ON menu.product_id = sales.product_id
   GROUP BY customer_id,
            product_name)
select customer_id, product_name 
from order_menu
where rank_num=1 ;
````
Result:

| customer_id | product_name |
| --- | --- |
| A | ramen |
| B | sushi |
| B | curry |
| B | ramen |
| C | ramen |

9.  Which item was purchased first by the customer after they became a member?
Query:
````sql
with customer_records as (select sales.customer_id, sales.order_date, sales.product_id, menu.product_name, members.join_date, 
rank() over (partition by sales.customer_id
			order by (sales.order_date - members.join_date))
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date>members.join_date)
select customer_id, product_name from customer_records
where rank=1;
````
Result:

| customer_id | product_name |
| --- | --- |
| A | ramen |
| B | sushi |

10.  Which item was purchased just before the customer became a member?
Query:
````sql
with customer_records as (select sales.customer_id, sales.order_date, sales.product_id, menu.product_name, members.join_date, 
rank() over (partition by sales.customer_id
			order by (sales.order_date - members.join_date))
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date<members.join_date)
select customer_id, product_name from customer_records
where rank=1;
````
Result:

| customer_id | product_name |
| --- | --- |
| A | sushi |
| A | curry |
| B | curry |

11.  What is the total items and amount spent for each member before they became a member?
Query:
````sql
select sales.customer_id, count(sales.product_id), sum(menu.price)
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date < members.join_date
group by sales.customer_id;
````
Result:

| customer_id | count | sum |
| --- | --- | --- |
| B | 3 | 40 |
| A | 2 | 25 |

12.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Query:
````sql
SELECT customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM menu 
INNER JOIN sales  ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;
````
Result:

| customer_id | customer_points |
| --- | --- |
| A | 860 |
| B | 940 |
| C | 360 |

13.  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
Query:
````sql
SELECT sales.customer_id, SUM(
CASE 
WHEN product_name='sushi' or (sales.order_date-join_date<7) THEN price*20
ELSE price*10
END) as customer_points
from sales 
join menu on sales.product_id = menu.product_id 
join members on sales.customer_id = members.customer_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;
````
Result:

| customer_id | customer_points |
| A | 1520 |
| B | 1240 |



/* What is the total amount each customer spent at the restaurant? */
SELECT sales.customer_id, SUM(menu.price) as total_sales
from sales
inner join menu on sales.product_id = menu.product_id
group by sales.customer_id;

/* How many days has each customer visited the restaurant? */
SELECT sales.customer_id, count(distinct order_date) from sales
group by sales.customer_id;

/* What was the first item from the menu purchased by each customer? */
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
		 
/* What is the most purchased item on the menu and how many times was it purchased by all customers? */
with id1 as
(with sale_count as (SELECT sales.product_id as prod_id, count(*) as prod_count from sales group by sales.product_id order by prod_count desc)
select prod_id from sale_count where (prod_count = (select max(prod_count) from sale_count)))
SELECT sales.customer_id, COUNT(*) AS purchase_count
FROM sales
JOIN id1 ON sales.product_id = id1.prod_id
GROUP BY sales.customer_id;

/* Which item was the most popular for each customer? */
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

/* Which item was purchased first by the customer after they became a member? */
with customer_records as (select sales.customer_id, sales.order_date, sales.product_id, menu.product_name, members.join_date, 
rank() over (partition by sales.customer_id
			order by (sales.order_date - members.join_date))
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date>members.join_date)
select customer_id, product_name from customer_records
where rank=1;

/* Which item was purchased just before the customer became a member? */
with customer_records as (select sales.customer_id, sales.order_date, sales.product_id, menu.product_name, members.join_date, 
rank() over (partition by sales.customer_id
			order by (sales.order_date - members.join_date))
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date<members.join_date)
select customer_id, product_name from customer_records
where rank=1;

/* What is the total items and amount spent for each member before they became a member? */
select sales.customer_id, count(sales.product_id), sum(menu.price)
from sales
join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where sales.order_date < members.join_date
group by sales.customer_id;

/* If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */
SELECT customer_id,
       SUM(CASE
               WHEN product_name = 'sushi' THEN price*20
               ELSE price*10
           END) AS customer_points
FROM menu 
INNER JOIN sales  ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id;

/* In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? */
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
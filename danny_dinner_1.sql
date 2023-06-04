CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

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
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


--descrition

select * from sales

select * from members

select * from menu

--What is the total amount each customer spent at the restaurant?

select * from sales 
inner join menu
on menu.product_id = sales.product_id


select customer_id, sum(menu.price) from sales
inner join menu
on sales.product_id = menu.product_id
group by sales.customer_id

--How many days has each customer visited the restaurant?

select customer_id, count( distinct (sales.order_date)) as days_visited from sales
group by sales.customer_id 


--What was the first item from the menu purchased by each customer?
with rank as (
select (customer_id), order_date , menu.product_id, menu.product_name,
rank() over ( partition by customer_id order by order_date  ) as  ranking
from sales
inner join menu
on menu.product_id = sales.product_id)
select * from rank where ranking = 1


--What is the most purchased item on the menu and how many times was it purchased by all customers?


select (count(menu.product_id)) as occurance, menu.product_name from sales
inner join menu
on menu.product_id =  sales.product_id
group by product_name
order by occurance desc


--Which item was the most popular for each customer?
with albab as (
With nadir as(
select (count(menu.product_id)) as occurance , sales.customer_id ,menu.product_name 
from sales
join menu
on menu.product_id = sales.product_id
group by menu.product_name , sales.customer_id)

select *,
rank() over( Partition by customer_id  order by occurance desc) as ranking
from nadir
order by customer_id)

select * from albab where ranking = 1 


--Which item was purchased first by the customer after they became a member?


with news as (
with mem as( 
select sales.customer_id, sales.product_id, order_date, members.join_date ,
rank() over (partition by sales.customer_id order by order_date ) as ranking
from  sales
inner join members
on sales.customer_id = members.customer_id
where sales.order_date >= members.join_date)

select * from mem
inner join menu
on mem.product_id = menu.product_id)


select * from news where ranking = 1


--Which item was purchased just before the customer became a member?

with newss as(
with mini as(
select sales.customer_id, sales.product_id, order_date, members.join_date ,
rank() over (partition by sales.customer_id order by order_date ) as ranking
from  sales
inner join members
on sales.customer_id = members.customer_id
where sales.order_date < members.join_date)


select * from mini
inner join menu
on mini.product_id = menu.product_id)



select * from newss where ranking = 1


--What is the total items and amount spent for each member before they became a member


With albab as( 
with nadir as(
select sales.customer_id ,sales.order_date,product_id from sales
left join members 
on members.customer_id = sales.customer_id
where order_date < join_date)
	

select menu.product_id,customer_id,product_name,order_date,menu.price from nadir 
inner join menu
on nadir.product_id = menu.product_id)

select albab.customer_id , count(distinct product_name), sum(price) 
from albab
group by customer_id







































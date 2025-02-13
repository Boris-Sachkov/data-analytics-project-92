--Расчет общего количества покупателей--
select count(customer_id) as customers_count
from customers;

--топ 10 продавцов с наибольшей выручкой--
with tab as (
select 
	s.*,
	p.price,
	(s.quantity * p.price) as income,
	concat(e.first_name , ' ', e.last_name ) as seller
from sales s 
inner join products p 
on s.product_id = p.product_id
inner join employees e 
on s.sales_person_id = e.employee_id
)

select 
	t.seller,
	count(t.seller) as operations,
	FLOOR(SUM(t.income)) as income
from tab t
group by t.seller
order by SUM(t.income) desc
limit 10;

--продавцы, чья выручка ниже средней выручки продавцов--
with tab as (
select 
	s.*,
	p.price,
	(s.quantity * p.price) as income,
	concat(e.first_name , ' ', e.last_name ) as seller
from sales s 
inner join products p 
on s.product_id = p.product_id
inner join employees e 
on s.sales_person_id = e.employee_id
)

select 
	t.seller,
	floor(avg(t.income)) as average_income
from tab t
group by t.seller
having floor(avg(t.income)) <
	(
		select 
			avg(t.income)
		from tab t
	)
order by avg(t.income) asc;

--данные по выручке по каждому продавцу и дню недели--
 with tab as (
select 
	s.*,
	p.price,
	(s.quantity * p.price) as amount,
	concat(e.first_name , ' ', e.last_name ) as seller
from sales s 
inner join products p 
on s.product_id = p.product_id
inner join employees e 
on s.sales_person_id = e.employee_id
)

select 
	t.seller,
	to_char(t.sale_date, 'day') as day_of_week,
	FLOOR(SUM(amount)) as income
from tab t
group by t.seller, to_char(t.sale_date, 'day'), to_char(t.sale_date, 'ID')
order by to_char(t.sale_date, 'ID'), t.seller;

--возрастные категории--
select 
	age_category,
	count(*) as age_count
from (
		select *,
			'16-25' as age_category
		from customers c 
		where age between 16 and 25
	
	union all 

		select *,
			'26-40' as age_category
		from customers c 
		where age between 26 and 40
	
	union all 

		select *,
			'40+' as age_category
		from customers c 
		where age > 40
	) as categorized_customers
	group by age_category
	order by age_category;

--Количество уникальных покупателей и выручка по месяцам--
with tab as
	(
		select s.*,
			CONCAT(to_char(sale_date, 'YYYY'),'-',to_char(sale_date, 'MM')) as selling_month,
			(s.quantity * p.price) as amount
		from sales s
		inner join products p 
		on s.product_id = p.product_id
	)
select 
	selling_month,
	count(distinct t.customer_id) as total_customers,
	FLOOR(sum(t.amount)) as income
from tab t
group by selling_month, EXTRACT(year from t.sale_date), EXTRACT(month from t.sale_date)
order by EXTRACT(year from t.sale_date), EXTRACT(month from t.sale_date);
	
--Покупатели, первая покупка которых пришлась на время проведения специальных акций--
with tab as 
(
select  
	s.*,
	p.price,
	(s.quantity * p.price) as amount,
	row_number () over (partition by s.customer_id order by s.customer_id, s.sale_date) as rn,
	concat(c.first_name, ' ', c.last_name) as customer,
	concat(e.first_name , ' ', e.last_name ) as seller
from sales s 
inner join products p
on s.product_id = p.product_id
inner join customers c
on s.customer_id = c.customer_id
inner join employees e 
on s.sales_person_id = e.employee_id
order by customer_id, sale_date
)

select 
	t.customer,
	t.sale_date,
	t.seller
from tab t
where rn = '1' and amount = '0'
order by customer_id;
-- Расчет общего количества покупателей --
select count(customer_id) as customers_count
from customers;

-- топ 10 продавцов с наибольшей выручкой --
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
	t.seller
from tab t
group by t.seller
order by SUM(t.amount) desc
limit 10;

-- продавцы, чья выручка ниже средней выручки продавцов --
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
),

tab1 as 
(
select 
	t.seller,
	sum(t.amount) as total_income
from tab t
group by t.seller
order by sum(t.amount) desc
)

select 
	t1.seller
from tab1 t1
where t1.total_income < 
	(
	select 
		avg(t1.total_income)
	from tab1 t1
	)
;

-- данные по выручке по каждому продавцу и дню недели --
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
	to_char(t.sale_date, 'DAY') as day_of_the_week,
	FLOOR(SUM(amount)) as total_income_by_days
from tab t
group by t.seller, to_char(t.sale_date, 'DAY'), to_char(t.sale_date, 'ID')
order by t.seller, to_char(t.sale_date, 'ID');


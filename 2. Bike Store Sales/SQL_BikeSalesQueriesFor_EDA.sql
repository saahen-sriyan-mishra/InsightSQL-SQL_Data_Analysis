-- data to work with
SELECT * from sales.orders
SELECT * from sales.customers
SELECT * from sales.order_items
SELECT * from production.products



--Customer Details
select 
	s_ord.customer_id, order_id,
	concat(s_cus.first_name,' ',s_cus.last_name) as 'Customer Full Name',
	s_cus.city, s_cus.state, s_ord.order_date
from sales.orders s_ord
Join sales.customers s_cus
on s_ord.customer_id = s_cus.customer_id
order by s_ord.customer_id, s_ord.order_id



-- sales volume & total volume generated
select 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name) as 'Customer Full Name',
	s_cus.city, s_cus.state, s_ord.order_date,
	sum(s_ord_ite.quantity) as total_units,
	sum(s_ord_ite.quantity * s_ord_ite.list_price) as revenue
from sales.orders s_ord

Join sales.customers s_cus
on s_ord.customer_id = s_cus.customer_id
join sales.order_items s_ord_ite
on s_ord.order_id =s_ord_ite.order_id

group by 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name),
	s_cus.city, s_cus.state, s_ord.order_date
order by s_cus.customer_id, s_ord.order_id



--Individual product unit and revenue from different customers
select 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name) as 'Customer Full Name',
	s_cus.city, s_cus.state, s_ord.order_date,
	sum(s_ord_ite.quantity) as total_units,
	sum(s_ord_ite.quantity * s_ord_ite.list_price) as revenue,
	p_pro.product_name
from sales.orders s_ord

Join sales.customers s_cus
on s_ord.customer_id = s_cus.customer_id
join sales.order_items s_ord_ite
on s_ord.order_id =s_ord_ite.order_id
join production.products p_pro
on p_pro.product_id =s_ord_ite.product_id

group by 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name),
	s_cus.city, s_cus.state, s_ord.order_date,
	p_pro.product_name
order by s_cus.customer_id, s_ord.order_id


--FINAL DATASET
--Individual product unit and revenue by categories and store and sales person, from different customers
select 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name) as 'Customer Full Name',
	s_cus.city, s_cus.state, s_ord.order_date,
	sum(s_ord_ite.quantity) as total_units,
	sum(s_ord_ite.quantity * s_ord_ite.list_price) as revenue,
	p_pro.product_name,
	p_cat.category_name,
	s_sto.store_name,
	CONCAT (s_sta.first_name, ' ', s_sta.last_name) as 'staff name'
from sales.orders s_ord

Join sales.customers s_cus
on s_ord.customer_id = s_cus.customer_id
join sales.order_items s_ord_ite
on s_ord.order_id =s_ord_ite.order_id
join production.products p_pro
on p_pro.product_id =s_ord_ite.product_id
join production.categories p_cat
on p_cat.category_id =p_pro.category_id
join sales.stores s_sto
on s_sto.store_id =s_ord.store_id
join sales.staffs s_sta
on s_sta.store_id =s_sto.store_id
group by 
	s_cus.customer_id, s_ord.order_id,
	concat(s_cus.first_name,' ',s_cus.last_name),
	s_cus.city, s_cus.state, s_ord.order_date,
	p_pro.product_name,
	p_cat.category_name,
	s_sto.store_name,
	CONCAT (s_sta.first_name, ' ', s_sta.last_name)
order by s_cus.customer_id, s_ord.order_id


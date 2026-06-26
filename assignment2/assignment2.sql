-- 1. non-optimized query

--explain analyze
select sub_3.cl_id, 
(
	select max(sub_1.cnt)
	from
	(
		select oc.id as cl_id, op.product_category, count(*) as cnt
		from opt_clients oc 
		join opt_orders oo on oo.client_id = oc.id 
		join opt_products op on op.product_id = oo.product_id
		where oc.status = 'active'
		group by cl_id, op.product_category
	) as sub_1
	where sub_1.cl_id = sub_3.cl_id
) as max,
(
	select min(sub_2.cnt)
	from
	(
		select oc.id as cl_id, op.product_category, count(*) as cnt
		from opt_clients oc 
		join opt_orders oo on oo.client_id = oc.id 
		join opt_products op on op.product_id = oo.product_id
		where oc.status = 'active'
		group by cl_id, op.product_category
	) as sub_2
	where sub_2.cl_id = sub_3.cl_id
) as min
from 
(
	select oc.id as cl_id, op.product_category, count(*) as cnt
	from opt_clients oc 
	join opt_orders oo on oo.client_id = oc.id 
	join opt_products op on op.product_id = oo.product_id
	where oc.status = 'active'
	group by cl_id, op.product_category
) as sub_3
group by sub_3.cl_id
limit 5

-- 2. optimized query

set enable_hashjoin = off

create index idx_client_id on opt_orders(client_id)
create index idx_client_status on opt_clients(status)
create index idx_product_id on opt_orders(product_id)

--explain analyze
with join_count as 
(
	select clients.id as client_id, products.product_category, count(*) as counted_per_category
	from opt_clients clients
	join opt_orders orders on clients.id = orders.client_id 
	join opt_products products on orders.product_id = products.product_id 
	where clients.status = 'active'
	group by clients.id, products.product_category 
),
statistics_client as 
(
	select client_id,
		max(counted_per_category) as maximum,
		min(counted_per_category) as minimum
	from join_count
	group by client_id
)
select client_id,  
		maximum,
		minimum
from statistics_client 
limit 5

set enable_hashjoin = on


create table customers (
    customer_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    balance numeric(10,2) default 0
);

create table products (
    product_id serial primary key,
    product_name varchar(100) not null,
    price numeric(10,2) not null,
    stock_quantity int not null
);

create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    order_date timestamp default current_timestamp,
    total_amount numeric(10,2) default 0
);

create table order_items (
    order_item_id serial primary key,
    order_id int references orders(order_id),
    product_id int references products(product_id),
    quantity int not null,
    price numeric(10,2) not null
);

create table order_log (
    log_id serial primary key,
    order_id int,
    customer_id int,
    action varchar(50),
    log_date timestamp default current_timestamp
);

-- task 1 — function: calculate order total

create or replace function calculate_order_total(p_order_id int)
returns int as $$
declare
	total numeric;
begin 
	select coalesce(sum(quantity * price), 0)
	into total
	from order_items
	where order_id = p_order_id;
	return total;
end;
$$ language plpgsql;

select *, calculate_order_total(1)
from order_items
where order_id = 1

-- task 2 — procedure: create new order

create or replace procedure create_order(p_customer_id int)
as $$
begin
	if not exists (select 1 from customers where customer_id = p_customer_id) 
	then raise exception 'Customer does not exist.';
	end if;
	insert into orders (customer_id, order_date, total_amount)
	values (p_customer_id, current_timestamp, 0);
end;
$$ language plpgsql;

call create_order(1)

-- task 3 — procedure: add product to order

create or replace procedure add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
as $$
declare
	new_stock_quantity int;
	new_price numeric;
begin
	if p_quantity <= 0
	then raise exception 'Quantity must be higher than 0.';
	end if;
	if not exists (select 1 from products where product_id = p_product_id)
	then raise exception 'Product does not exist.';
	end if;
	if not exists (select 1 from orders where order_id = p_order_id)
	then raise exception 'Order does not exist.';
	end if;
	select stock_quantity - p_quantity
	into new_stock_quantity
	from products
	where p_product_id = product_id;
	if new_stock_quantity < 0
	then raise exception 'Not enough items in the stock.';
	end if;
	select price
	into new_price
	from products
	where p_product_id = product_id;
	insert into order_items (order_id, product_id, quantity, price)
	values (p_order_id, p_product_id, p_quantity, new_price);
	update products 
	set stock_quantity = new_stock_quantity
	where p_product_id = product_id;
end;
$$ language plpgsql;

call add_product_to_order(1, 1, 3)

-- task 4 — trigger: update order total

create or replace function update_total()
returns trigger as $$
declare 
	ord_id int;
	new_total numeric;
begin 
	if tg_op = 'DELETE' 
	then ord_id = old.order_id;
	else ord_id = new.order_id;
	end if;
	new_total := calculate_order_total(ord_id);
	update orders
	set total_amount = new_total
	where order_id = ord_id;
	return null;
end;
$$ language plpgsql;

create trigger update_order_total
after insert or update or delete on order_items
for each row
execute function update_total();

-- task 5 — trigger: order audit log



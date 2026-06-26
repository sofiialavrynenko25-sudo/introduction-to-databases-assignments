Short descriptions for every task:

1. task 1
- coalesce is performed, where the result is either sum(quantity * price) or 0
- the value is written to total (declared in declare)
- total is returned

2. task 2
- checking if a customer with this id exists
- if not, an error message is displayed
- a new record is added to orders table (customer_id is passed as a parameter, order_date as the current time, total_amount as 0)

3. task 3
- cchecking that quantity is greater than 0
- checking that product with this id exists
- checking that order with this id exists
- calculating new quantity (new_stock_quantity from declare)
- checking that new quantity is greater than or equal to 0
- writing price from products table to new_price (from declare)
- a new record is added to orders_items table (order_id, product_id, quantity passed as parameters, new_price written above)
- update products table (quantity is decreased)

4. task 4
First, the update_total function is created for the trigger:
    - returns trigger means that this function is specifically for the trigger and it gets access to old, new, tg_op
    - if the action was delete, then ord_id (from declare) will be the id that was just deleted (through old)
    - if not, then ord_id will be the one that is inserted or changed (through new)
    - new_total (from declare) is calculated through calculate_order_total, that is, through the function from task 1
    - orders table is updated, a new total_amount is set
    - return null, because the function must return something, and the trigger will work with after
Then an update_order_total trigger is created:
    - after inserting, updating or deleting in order_items the update_total function is executed

5. task 5
First, the add_log function is created for the trigger:
    - returns trigger same as in task 4
    - if the action was delete then ord_id and cust_id (from declare) will be the ids that were just deleted (through old)
    - if not then ord_id and cust_id will be the ones that are being inserted or changed (through new)
    - a new record is created in order_items (order_id as ord_id, customer_id as cust_id, action via tg_op to record what exactly was done, and log_date as the current time)
    - return null same as in task 4
Then an order_audit_log trigger is created:
    - after inserting, updating or deleting in orders the add_log function is executed

2. a short explanation of how PostgreSQL executes the query
- SeqScan for order_items, to flter rows where order_id = 1
- a hash table is created from the filtered rows via Hash
- SeqScan to read from products table
- Hash Join is used to search for matches in the hash table, with the condition that product_id from the products table is equal to product_id from the order_items table

3. identification of whether PostgreSQL uses a Sequential Scan, Index Scan, Hash Join, Nested Loop, or another operation
- SeqScan (filter the order_items table and read the products table)
- Hash (create a hash table with filtered rows)
- Hash Join (join based on a hash table)
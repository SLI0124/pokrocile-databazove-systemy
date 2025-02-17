select (select count(*) from customer)  as customer_count,
       (select count(*) from [Order])   as order_count,
       (select count(*) from OrderItem) as order_item_count,
       (select count(*) from Product)   as product_count,
       (select count(*) from staff)     as staff_count,
       (select count(*) from store)     as store_count;

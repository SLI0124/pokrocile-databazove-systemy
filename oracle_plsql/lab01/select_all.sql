SELECT (SELECT COUNT(*) FROM customer)  AS customer_count,
       (SELECT COUNT(*) FROM "Order")   AS order_count,
       (SELECT COUNT(*) FROM OrderItem) AS order_item_count,
       (SELECT COUNT(*) FROM Product)   AS product_count,
       (SELECT COUNT(*) FROM staff)     AS staff_count,
       (SELECT COUNT(*) FROM store)     AS store_count
FROM dual;

-- create and generate tables and its data from scratch

select degree
from dba_tables
where table_name = 'CUSTOMER' and owner='SLI0124'; --1, we're gucci

-- 6.3
explain plan for

SELECT oi.*, p.*, o.*
FROM OrderItem oi
INNER JOIN Product p ON oi.idProduct = p.idProduct
INNER JOIN "Order" o ON oi.idOrder = o.idOrder
WHERE p.name LIKE 'Auto%'
  AND EXTRACT(YEAR FROM o.order_datetime) = 2022
  AND oi.unit_price BETWEEN 1000000 AND 1010000; --23
  
-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 1756391429   
  
set feedback on SQL_ID;
set feedback off SQL_ID; -- 2nkchuhh91gpz

-- get all the stats
exec PrintQueryStat('2nkchuhh91gpz', 1756391429);

select count(*)
from orderitem oi
where oi.unit_price BETWEEN 1000000 AND 1010000; -- 2 820
  
select count(*)
from orderitem; -- 5 000 010
  
select count(*)
from product p
where p.name LIKE 'Auto%'; -- 1 691

SELECT count(*)
from product; -- 100 000
  
select count(*)
from "Order" o
where EXTRACT(YEAR FROM o.order_datetime) = 2022; --21 677

select count(*)
from "Order"; -- 500 510 => (21 677 / 500 510) * 100% = 4,33%

-- this index should be alright
CREATE INDEX custom_index ON OrderItem (idProduct, idOrder, unit_price);

-- 6.4.
explain plan for

SELECT COUNT(*) AS order_item_count, SUM(oi.quantity) AS total_quantity
FROM OrderItem oi
INNER JOIN Product p ON oi.idProduct = p.idProduct
INNER JOIN "Order" o ON oi.idOrder = o.idOrder
WHERE p.name LIKE 'Auto%'
  AND EXTRACT(YEAR FROM o.order_datetime) = 2022
  AND oi.unit_price BETWEEN 1000000 AND 1010000; --23

select * from table(dbms_xplan.display); -- hash value: 1756391429   

-- this ain't it, since I coudln't execute PrintQueryStat, I was blind and couldn't see
-- what if the CPU time or IO cost is better, also creating index took forever,
-- so if anybody will use this, create better index
CREATE INDEX custom_index ON OrderItem (idProduct, idOrder, unit_price, quantity);
drop index custom_index;

-- 1475383585
-- 89x7zkr9q6m0p

exec PrintQueryStat('89x7zkr9q6m0p', 1475383585);

-- index_order
select index_name
from USER_INDEXES
where TABLE_NAME = 'Order';

-- index_orderitem
select index_name
from USER_INDEXES
where TABLE_NAME = 'ORDERITEM';

-- index_product
select index_name
from USER_INDEXES
where TABLE_NAME = 'PRODUCT';
-- firstly, drop all tables and generate new data

-- 6.1.
-- we measure CPU time using sys.dm_exec_query_stats
-- to get average time for multiple runs
-- his means, if time on shows 0, use sys.dm_exec_query_stats
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT oi.*, p.*
FROM OrderItem oi
INNER JOIN Product p ON oi.idProduct = p.idProduct
WHERE p.unit_price BETWEEN 20000000 AND 20002000
option (maxdop 1);

select *
from OrderItem 
WHERE unit_price BETWEEN 20000000 AND 20002000 -- 41

select count(*)
from OrderItem; -- 5 000 000

select *
from Product 
WHERE unit_price BETWEEN 20000000 AND 20002000 --1

select count(*)
from Product; -- 100 000

--since product is smaller query result, we optimaze bigger query result, hence
-- this didn't work
-- create index super_oi_index on OrderItem (idOrder, idProduct, unit_price);
-- drop index super_oi_index on OrderItem;

-- do not include the pripary key of the bigger table, dspise it is clustered piramry index
create index super_oi_index on OrderItem (idProduct, unit_price);

exec printindexes 'OrderItem';

-- now we get stats for same query with improved time and CPU
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT oi.*, p.*
FROM OrderItem oi
INNER JOIN Product p ON oi.idProduct = p.idProduct
WHERE p.unit_price BETWEEN 20000000 AND 20002000
option (maxdop 1);



-- 6.2.
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT COUNT(*) AS order_item_count, SUM(oi.quantity) AS total_quantity
FROM OrderItem oi 
INNER JOIN Product p ON oi.idProduct = p.idProduct
WHERE p.unit_price BETWEEN 20000000 AND 20002000
option (maxdop 1);

-- since we are asking about quantity, which is not in join, where or group by clause
-- we simply create including index

exec printindexes 'OrderItem';

CREATE INDEX super_oi_index ON OrderItem (idProduct, unit_price) INCLUDE (quantity);

-- if the time is zero, get first result in mili mili seconds
SELECT qs.execution_count, 
 SUBSTRING(qt.text,qs.statement_start_offset/2 +1,   
                 (CASE WHEN qs.statement_end_offset = -1   
                       THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2   
                       ELSE qs.statement_end_offset end -  
                            qs.statement_start_offset  
                 )/2  
             ) AS query_text,
qs.total_worker_time/qs.execution_count AS avg_cpu_time, qp.dbid, qt.text  
--   qs.plan_handle, qp.query_plan   
FROM sys.dm_exec_query_stats AS qs  

-- this should be all
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) as qp  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt  
where qp.dbid=DB_ID() and qs.execution_count > 10
--and qt.text LIKE '%SELECT * FROM Customer%'
ORDER BY avg_cpu_time DESC; 
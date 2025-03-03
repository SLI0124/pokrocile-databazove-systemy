-- we must find less or 100 records, we DO NOT use primary key in this query
-- just find some range that will return <= 100 records till you get it right
SELECT count(*)
FROM orderitem
WHERE unit_price between 21000 and 21001;

set feedback on SQL_ID;

SELECT *
FROM OrderItem
WHERE unit_price between 21000 and 21001;

set feedback off SQL_ID;

-- SQL_ID: 15pq11jt0544q

-- this doesn't do shit, it fills table for next query
explain plan for
SELECT *
FROM OrderItem
WHERE unit_price between 21000 and 21001;

select * from table (dbms_xplan.display);

-- plan hash: 4294024870

exec printquerystat('15pq11jt0544q',4294024870);

-- heap stats
call PRINTPAGES('ORDERITEM', 'SLI0124');

-- without printquerystat, do not use
--col username format a10 ;
--col sql_text format a30 ;
--
--select executions as executions,
--  buffer_gets/executions as buffer_gets,
--  (cpu_time/executions)/1000.0 as cpu_time_ms,
--  (elapsed_time/executions)/1000.0 as elapsed_time_ms,
--  rows_processed/executions as rows_processed,
--  du.username, sql_text
--from v$sql
--inner join dba_users du on du.user_id=parsing_user_id
--where sql_id='15pq11jt0544q' and plan_hash_value=4294024870;

-- if degree is 1, it means that single core was used, therefore it was sequential
-- we get 1, so we don't need to do 3.2. task for Oracle
select degree
from dba_tables
where table_name = 'ORDERITEM' and owner='SLI0124';

-- 3.3.1.
-- 3.3.1 delete ~1/2 of the records in OrderItem
select count(*)
from orderitem; -- 5 000 010

delete from ORDERITEM where mod(idProduct, 2) = 0;

select count(*)
from orderitem; -- 2 500 499

-- and do the same stuff for this

SELECT count(*)
FROM orderitem
WHERE unit_price between 21000 and 21001;

-- SQL_ID: 15pq11jt0544q
-- plan hash value: 4294024870
call printquerystat('15pq11jt0544q',4294024870);

-- heap stats
call PRINTPAGES('ORDERITEM', 'SLI0124');

-- 3.3.3 physically delete ~1/2 of the records in OrderItem

ALTER TABLE OrderItem ENABLE ROW MOVEMENT;
alter table OrderItem shrink space;

-- and do the same stuff for this

-- SQL_ID: 15pq11jt0544q
-- plan hash value: 4294024870
call printquerystat('15pq11jt0544q',4294024870);

-- heap stats
call PRINTPAGES('ORDERITEM', 'SLI0124');
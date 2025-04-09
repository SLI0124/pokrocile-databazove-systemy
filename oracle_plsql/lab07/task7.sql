-- 8.3.1.
ALTER SESSION SET NLS_SORT = CZECH;

-- SET SERVEROUTPUT OFF


exec PRINTPAGES('ORDERITEM' , 'SLI0124');

-- 8.3.2.
-- first query´
explain plan for
select avg(unit_price) from OrderItem;

select * from table(dbms_xplan.display); -- 1670445072


set feedback on SQL_ID;
set feedback off SQL_ID; -- 6pg92dfxaqwg2

exec PrintQueryStat('6pg92dfxaqwg2', 1670445072);

-- second query
explain plan for
select avg(unit_price) , quantity from OrderItem group by quantity;

select * from table(dbms_xplan.display); -- 2014048680


set feedback on SQL_ID;
set feedback off SQL_ID; -- d2jpqtgxcf3v2

exec PrintQueryStat('d2jpqtgxcf3v2', 2014048680);

-- convert to columnar table, query low is implicit, aka default type
-- alter table OrderItem INMEMORY; -- this should be the same as command after
-- but I don't want to risk it
ALTER TABLE OrderItem INMEMORY MEMCOMPRESS FOR QUERY LOW;

select v.segment_name name, v.inmemory_size
from v$im_segments v;

-- first query´
explain plan for
select avg(unit_price) from OrderItem;

select * from table(dbms_xplan.display); -- 1670445072

set feedback on SQL_ID;
set feedback off SQL_ID; -- 6pg92dfxaqwg2

exec PrintQueryStat('6pg92dfxaqwg2', 1670445072);

-- second query
explain plan for
select avg(unit_price) , quantity from OrderItem group by quantity;

select * from table(dbms_xplan.display); -- 2014048680


set feedback on SQL_ID;
set feedback off SQL_ID; -- d2jpqtgxcf3v2

exec PrintQueryStat('d2jpqtgxcf3v2', 2014048680);

-- convert to columnar table, query high is implicit, aka default type
ALTER TABLE OrderItem INMEMORY MEMCOMPRESS FOR CAPACITY HIGH;

select v.segment_name name, v.inmemory_size
from v$im_segments v;

-- first query´
explain plan for
select avg(unit_price) from OrderItem;

select * from table(dbms_xplan.display); -- 1670445072

set feedback on SQL_ID;
set feedback off SQL_ID; -- 6pg92dfxaqwg2

exec PrintQueryStat('6pg92dfxaqwg2', 1670445072);

-- second query
explain plan for
select avg(unit_price) , quantity from OrderItem group by quantity;

select * from table(dbms_xplan.display); -- 2014048680


set feedback on SQL_ID;
set feedback off SQL_ID; -- d2jpqtgxcf3v2

exec PrintQueryStat('d2jpqtgxcf3v2', 2014048680);











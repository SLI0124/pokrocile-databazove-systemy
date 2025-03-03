-- we must find less or 100 records, we DO NOT use primary key in this query
-- just find some range that will return <= 100 records till you get it right
SELECT count(*)
FROM OrderItem
WHERE unit_price between 21007 and 21008;

-- after you find it, use this command for all stats below
SELECT *
FROM OrderItem
WHERE unit_price between 21007 and 21008;

-- smaller text QEP
set showplan_text on;
set showplan_text off;

-- bigger text QEP, get 
SET SHOWPLAN_ALL ON;
SET SHOWPLAN_ALL OFF;

-- get the IO cost, look for "logical reads"
SET STATISTICS IO ON;
SET STATISTICS IO OFF;

-- get CPU time and ELAPSED time, got buch of ones, look for non null ones
SET STATISTICS TIME ON;
SET STATISTICS TIME OFF;

-- somewhere alongside QEP output, we got parallel, do it again with this 
-- to do it sequentially, once again...
SELECT *
FROM OrderItem
WHERE unit_price between 21007 and 21008
option (MAXDOP 1);

-- heap stats
exec PrintPagesHeap 'OrderItem';

-- 3.3.1 delete ~1/2 of the records in OrderItem
select count(*)
from OrderItem; -- 5 000 000

delete
from ORDERITEM
where idProduct % 2 = 0;

select count(*)
from OrderItem; -- 2 500 022

SELECT count(*)
FROM OrderItem
WHERE unit_price between 21007 and 21008;

SELECT *
FROM OrderItem
WHERE unit_price between 21007 and 21008
option (MAXDOP 1);

-- heap stats
exec PrintPagesHeap 'OrderItem';

-- 3.3.3 physically delete ~1/2 of the records in OrderItem

alter table OrderItem
    rebuild;

SELECT count(*)
FROM OrderItem
WHERE unit_price between 21007 and 21008;

SELECT *
FROM OrderItem
WHERE unit_price between 21007 and 21008
option (MAXDOP 1);

-- heap stats
exec PrintPagesHeap 'OrderItem';
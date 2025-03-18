select count(*)
from customer;

SELECT count(*)
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana' AND residence = 'Pardubice';

SELECT lname, fname, residence, COUNT(*) AS count_records
FROM Customer
GROUP BY lname, fname, residence
ORDER BY count_records;

SELECT lname, fname, COUNT(*) AS count_records
FROM Customer
GROUP BY lname, fname
ORDER BY count_records;

SELECT lname, residence, COUNT(*) AS count_records
FROM Customer
GROUP BY lname, residence
ORDER BY count_records;

-- 4.1. 
SELECT MIN(count_records) AS min_count, MAX(count_records) AS max_count
FROM (
    SELECT lname, fname, residence, COUNT(*) AS count_records
    FROM Customer
    GROUP BY lname, fname, residence
) AS subquery;

-- 4.2.
SELECT MIN(count_records) AS min_count, MAX(count_records) AS max_count
FROM (
    SELECT lname, fname, COUNT(*) AS count_records
    FROM Customer
    GROUP BY lname, fname
) AS subquery;

-- 4.3.
SELECT MIN(count_records) AS min_count, MAX(count_records) AS max_count
FROM (
    SELECT lname, residence, COUNT(*) AS count_records
    FROM Customer
    GROUP BY lname, residence
) AS subquery;

-- 4.4. 
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT count(*)
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana' AND residence = 'Pardubice'
option (maxdop 1);

--create index
SET NOCOUNT ON;
DECLARE @StartTime DATETIME = GETDATE();

CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

DECLARE @EndTime DATETIME = GETDATE();
SELECT DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS ExecutionTimeMS;

-- delete index, if you screw up
-- DROP INDEX customer_name_res ON Customer;

-- get the index size and blocks
-- get the index name
exec PrintIndexes 'Customer';
go

-- pk: PK__Customer__D0587687343333B0
-- our index: customer_name_res

exec PrintPagesIndex 'customer_name_res';

-- same thing as before but with index now
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana' AND residence = 'Pardubice'
option (maxdop 1);

-- lowest
-- lname: Vesel�, fname: Petr -- 761
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT *
FROM Customer
WHERE lname = 'Veselý' AND fname = 'Petr'
option (maxdop 1);


-- highest
-- lname: Vesel�, fname: Jana -- 1220
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana'
option (maxdop 1);

-- 4.7. size of pk index, new index and heap
-- get the index size and blocks
-- get the index name
exec PrintIndexes 'Customer';
go

-- pk: PK__Customer__D0587687343333B0
-- our index: customer_name_res
exec PrintPagesIndex 'PK__Customer__D0587687343333B0';

exec PrintPagesIndex 'customer_name_res';

exec PrintPagesHeap 'Customer';
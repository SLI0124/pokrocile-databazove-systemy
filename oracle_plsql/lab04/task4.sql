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
);

-- 4.2.
SELECT MIN(count_records) AS min_count, MAX(count_records) AS max_count
FROM (
    SELECT lname, fname, COUNT(*) AS count_records
    FROM Customer
    GROUP BY lname, fname
);

-- 4.3.
SELECT MIN(count_records) AS min_count, MAX(count_records) AS max_count
FROM (
    SELECT lname, residence, COUNT(*) AS count_records
    FROM Customer
    GROUP BY lname, residence
);

-- 4.4.
-- check how many core we are using for paralelism checking
select degree
from dba_tables
where table_name = 'CUSTOMER' and owner='SLI0124'; -- 1 - we're good

-- 70 records, randomized values, use first query to get row with tens of records
-- lname: Veselá, Nováková
-- fname: Jana, Alena
-- residence: Pardubice, Přerov

-- this only fills table dbms_xplan.display, this will only save it
EXPLAIN PLAN FOR
SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana' AND residence = 'Pardubice';

-- here we can get the plan hash value by running it: 2844954298
select * from table(dbms_xplan.display);

-- we must run set feedback on by F5 (:
set feedback on SQL_ID;
SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Jana' AND residence = 'Pardubice';
set feedback off SQL_ID; -- SQL_ID: bs9k9yaqsxmjf

-- exec PrintQueryStat(’<sql_id>’, <plan_hash_value>);
exec PrintQueryStat('bs9k9yaqsxmjf', 2844954298);


-- 4.5.
CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

select index_name
from USER_INDEXES
where TABLE_NAME = 'CUSTOMER'; --SYS_C0025025, CUSTOMER_NAME_RES

-- index size and blocks
-- this is the percentage, do not use this one
exec PrintPages_space_usage('CUSTOMER_NAME_RES', 'SLI0124', 'INDEX');
-- use this one instead
exec PrintPages_unused_space('CUSTOMER_NAME_RES', 'SLI0124', 'INDEX');


-- plan hash value: 3304523282
-- SQL_ID: bs9k9yaqsxmjf
exec PrintQueryStat('bs9k9yaqsxmjf', 3304523282);


-- 4.6.
-- lowest: Nováková, Alena, 642
-- highest: Veselá, Věra, 2886

-- lowest: 
set feedback on SQL_ID;
SELECT *
FROM Customer
WHERE lname = 'Nováková' AND fname = 'Alena';
set feedback off SQL_ID; 

-- SQL_ID: 34fugrh94jg2z


EXPLAIN PLAN FOR 
SELECT *
FROM Customer
WHERE lname = 'Nováková' AND fname = 'Alena';

select * from table(dbms_xplan.display);

-- plan hash value: 2844954298

exec PrintQueryStat('34fugrh94jg2z', 2844954298);

SELECT count(*)
FROM Customer
WHERE lname = 'Nováková' AND fname = 'Alena';


-- highest

set feedback on SQL_ID;
SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Věra';
set feedback off SQL_ID; 

-- SQL_ID: d8g1xpnag6kx7

EXPLAIN PLAN FOR 
SELECT *
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Věra';

select * from table(dbms_xplan.display);

-- plan has value: 2844954298

SELECT count(*)
FROM Customer
WHERE lname = 'Veselá' AND fname = 'Věra';

exec PrintQueryStat('d8g1xpnag6kx7', 2844954298);

-- 4.7.
select index_name
from USER_INDEXES
where TABLE_NAME = 'CUSTOMER'; --SYS_C0025025, CUSTOMER_NAME_RES

-- primary key index
exec PrintPages_unused_space('SYS_C0025025', 'SLI0124', 'INDEX');

-- our index
exec PrintPages_unused_space('CUSTOMER_NAME_RES', 'SLI0124', 'INDEX');

-- heap blocks customer, budeme potřebovat až na konci
call PRINTPAGES('CUSTOMER', 'SLI0124');



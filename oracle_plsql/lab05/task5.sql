-- firstly create tables normally, just like gazillion times before

-- check how many core we are using for paralelism check, just to be sure
select degree
from dba_tables
where table_name = 'CUSTOMER' and owner='SLI0124'; --1, we're gucci

-- stats for heap for first PDF table
call PrintPages('CUSTOMER', 'SLI0124');

-- get the index name for PK, should be only one at the moment
select index_name
from USER_INDEXES
where TABLE_NAME = 'CUSTOMER'; -- SYS_C0026530

-- stats for index for first PDF table
exec PrintPages_unused_space('SYS_C0026530', 'SLI0124', 'INDEX');

-- now we need to do projection * on one primary key - point query
-- this will populate table bellow
explain plan for
select *
from customer
where idcustomer = 12345;

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 4187801518

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where idcustomer = 12345;

set feedback off SQL_ID; -- 1fk55ms1b0tzj

-- get all the stats
exec PrintQueryStat('1fk55ms1b0tzj', 4187801518);

-- now we need to do it for tens of records - range query
-- pick some random combo of lname, fname, residence with tens of count_records
SELECT lname, fname, residence, COUNT(*) AS count_records
FROM Customer
GROUP BY lname, fname, residence
ORDER BY count_records;
-- lname: Marková
-- fname: Hana
-- residence: Jihlava
-- count_records: 72

-- now that we have our combination, do it all over again
-- this will populate table bellow
explain plan for
select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 2844954298

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

set feedback off SQL_ID; -- 51bfnfhk5rhr6

-- get all the stats
exec PrintQueryStat('51bfnfhk5rhr6', 2844954298);

-- now we need to create multiple attribute index on attributes lname, fname,
-- residence named "customer_name_res"
CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

-- once again we need to do the same thing
-- this will populate table bellow
explain plan for
select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 3304523282

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

set feedback off SQL_ID; -- 51bfnfhk5rhr6

-- get all the stats
exec PrintQueryStat('51bfnfhk5rhr6', 3304523282);

-- okay, now we got everything for heap tables
-- we will proceed to clustered tables
-- because Oracle doesn't support transition from heap to clustered, 
-- we need to create every table with ") organization index;" at the end

drop table OrderItem;
drop table "Order";
drop table Staff;
drop table Store;
drop table Product;
drop table Customer;
drop type idProductArrayType;

create table Customer
(
    idCustomer int primary key,
    fName      varchar(20) not null,
    lName      varchar(30) not null,
    residence  varchar(20) not null,
    gender     char(1)     not null,
    birthday   date        not null
) organization index;

create table Product
(
    idProduct   int primary key,
    name        varchar(30)   not null,
    unit_price  int           not null,
    producer    varchar(30)   not null,
    description varchar(2000) null
) organization index;

create table Store
(
    idStore   int primary key,
    name      varchar(30) not null,
    residence varchar(20) not null
) organization index;

create table Staff
(
    idStaff        varchar(7) primary key,
    fName          varchar(20)                    not null,
    lName          varchar(30)                    not null,
    residence      varchar(20)                    not null,
    gender         char(1)                        not null,
    birthday       date                           not null,
    start_contract date                           not null,
    end_contract   date default null,
    idStore        int references Store (idStore) not null
) organization index;

create table "Order"
(
    idOrder        int primary key,
    order_datetime date                                  not null,
    idCustomer     int references Customer (idCustomer)  not null,
    order_status   varchar2(10),
    idStore        int references Store (idStore)        not null,
    idStaff        varchar(7) references Staff (idStaff) not null
) organization index;

create table OrderItem
(
    idOrder    int references "Order" (idOrder)   not null,
    idProduct  int references Product (idProduct) not null,
    unit_price int                                not null,
    quantity   int                                not null,
    primary key (idOrder, idProduct)
) organization index;

create type idProductArrayType is table of int; -- Product.idProduct%type  

-- as I see it now, I could have done it only for table Customer, one can never
-- be sure so let's make it once and thoroughly
-- okay, now we re-populate tables

insert into Customer select * from ProductOrder.Customer;
insert into Product select * from ProductOrder.Product;
insert into Store select * from ProductOrder.Store;
insert into Staff select * from ProductOrder.Staff;
insert into "Order" select * from ProductOrder."Order";
insert into OrderItem select * from ProductOrder.OrderItem;
commit;

-- check count just to be sure

SELECT 
    (SELECT COUNT(*) FROM customer) AS customer_count,
    (SELECT COUNT(*) FROM "Order") AS order_count,
    (SELECT COUNT(*) FROM OrderItem) AS order_item_count,
    (SELECT COUNT(*) FROM Product) AS product_count,
    (SELECT COUNT(*) FROM staff) AS staff_count,
    (SELECT COUNT(*) FROM store) AS store_count
FROM dual;

-- we can't use page utilization in Oracle, so we will do it in SQL Server

-- same thing as it was in the beginning
-- now index and heap are the same, we get same output, demonstrate now,
-- later we can use just PrintPages, this goes to first PDF table

call PrintPages('CUSTOMER', 'SLI0124');

-- get the index name for PK
select index_name
from USER_INDEXES
where TABLE_NAME = 'CUSTOMER'; -- SYS_IOT_TOP_323631

exec PrintPages_unused_space('SYS_IOT_TOP_323631', 'SLI0124', 'INDEX');
-- or you can use: exec PrintPages_unused_space('CUSTOMER', 'SLI0124', 'TABLE');

-- now we shrink the table

-- alter table Customer enable row movement; -- didn't do shit
alter table Customer shrink space;

-- we get new shrinked statistics to the first PDF table
call PrintPages('CUSTOMER', 'SLI0124');


-- now we need to do projection * on one primary key - point query, again
-- this will populate table bellow
explain plan for
select *
from customer
where idcustomer = 12345;

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 944086201

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where idcustomer = 12345;

set feedback off SQL_ID; -- 1fk55ms1b0tzj

-- get all the stats
exec PrintQueryStat('1fk55ms1b0tzj', 944086201);


-- now we need to do it for tens of records - range query
-- I will keep the same as before, miraculously we get the same record count
-- lname: Marková
-- fname: Hana
-- residence: Jihlava
-- count_records: 72

-- now that we have our combination, do it all over again
-- this will populate table bellow
explain plan for
select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 497481151

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

set feedback off SQL_ID; -- 51bfnfhk5rhr6

-- get all the stats
exec PrintQueryStat('51bfnfhk5rhr6', 497481151);


-- now we need to create multiple attribute index "customer_name_res", again, 
-- this time it is on clustered table 
CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

-- once again we need to do the same thing
-- this will populate table bellow
explain plan for
select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

-- get hash value and QEP
select * from table(dbms_xplan.display); -- hash value: 3360359535

-- get SQL_ID
set feedback on SQL_ID;

select *
from customer
where lname='Marková' AND fname='Hana' AND residence = 'Jihlava';

set feedback off SQL_ID; -- 51bfnfhk5rhr6

-- get all the stats
exec PrintQueryStat('51bfnfhk5rhr6', 3360359535);

-- that should be all folks...
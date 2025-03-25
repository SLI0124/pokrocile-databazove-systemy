-- firstly create tables normally, just like gazillion times before

-- stats for heap for first PDF table
exec PrintPagesHeap 'Customer';

-- get the index name
exec PrintIndexes 'Customer'; -- PK__Customer__D0587687DDFBD4C9

-- stats for index for the first PDF table
exec PrintPagesIndex 'PK__Customer__D0587687DDFBD4C9';

-- now we need to do projection * on one primary key - point query
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where idcustomer = 12345
option (maxdop 1); -- ensure non-parallelism

-- now we need to do it for tens of records - range query
-- pick some random combo of lname, fname, residence with tens of count_records
SELECT lname, fname, residence, COUNT(*) AS count_records
FROM Customer
GROUP BY lname, fname, residence
ORDER BY count_records;
-- lname: Èerná
-- fname: Lenka
-- residence: Pøerov
-- count_records: 72

set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where lName='Èerná' AND fName='Lenka' AND residence='Pøerov'
option (maxdop 1);

-- okay, now we need to create index
CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

-- this is just for check, should give PK and "customer_name_res"
exec PrintIndexes 'Customer'; 

-- once again, again, again, again, again, again, ...
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where lName='Èerná' AND fName='Lenka' AND residence='Pøerov'
option (maxdop 1);

-- amazing, now we drop heap tables and make them clustered
-- SQL Server allows to transfer them directly, there are side effects 
-- of this procedure
-- for simplicity and unity, we will drop them and create them clutered

drop table IF EXISTS OrderItem
drop table IF EXISTS "Order"
drop table IF EXISTS Staff
drop table IF EXISTS Store
drop table IF EXISTS Product
drop table IF EXISTS Customer

create table Customer (
	idCustomer int primary key, -- before it was: idCustomer int primary key nonclustered,
	fName varchar(20) not null,
	lName varchar(30) not null,
	residence varchar(20) not null,
	gender char(1) not null,
	birthday date not null
);

create table Product (
	idProduct int primary key,
	name varchar(30) not null,
	unit_price int not null,
	producer varchar(30) not null,
	description varchar(2000) null
);


create table Store (
	idStore int primary key,
	name varchar(30) not null,
	residence varchar(20) not null
);

create table Staff (
	idStaff varchar(7) primary key,
	fName varchar(20) not null,
	lName varchar(30) not null,
	residence varchar(20) not null,
	gender char(1) not null,
	birthday date not null,
	start_contract date not null,
	end_contract date default null,
	idStore int references Store(idStore) not null
);

create table "Order" (
	idOrder int primary key,
	order_datetime date not null,
	idCustomer int references Customer(idCustomer) not null,
	order_status varchar(10),
	idStore int references Store(idStore) not null,
	idStaff varchar(7) references Staff(idStaff) not null
);

create table OrderItem (
	idOrder int references "Order"(idOrder) not null,
	idProduct int references Product(idProduct) not null,
	unit_price bigint not null,
	quantity int not null,
	primary key (idOrder, idProduct)
); 

-- we need to also repopulate them
insert into dbo.Customer select * from ProductOrder.dbo.Customer;
insert into dbo.Product select * from ProductOrder.dbo.Product;
insert into dbo.Store select * from ProductOrder.dbo.Store;
insert into dbo.Staff select * from ProductOrder.dbo.Staff;
insert into dbo."Order" select * from ProductOrder.dbo."Order";
insert into dbo.OrderItem select * from ProductOrder.dbo.OrderItem;

-- check count
SELECT 'customer_count' AS name, COUNT(*) AS count FROM customer
UNION ALL
SELECT 'order_count', COUNT(*) FROM "Order"
UNION ALL
SELECT 'order_item_count', COUNT(*) FROM OrderItem
UNION ALL
SELECT 'product_count', COUNT(*) FROM Product
UNION ALL
SELECT 'staff_count', COUNT(*) FROM staff
UNION ALL
SELECT 'store_count', COUNT(*) FROM store;

-- we have some records, let's fill the rest of the first PDF table
-- exec PrintPagesHeap 'Customer'; this doesn't return anyhting, guess heap's no longer accessible

-- compile this once
GO
create or alter procedure PrintPagesClusterTable 
  @tableName varchar(30)
as
begin
  exec PrintPages @tableName, 1
end;

-- clustered table stats for first PDF table
exec PrintPagesClusterTable 'Customer';

-- get index name for pages utilization in %
exec PrintIndexes 'Customer'; -- PK__Customer__D0587687DDFBD4C9

-- this is print just for me, 
--check if table is clustered, total and used pages (just check it) and gets PK name
SELECT 
t.NAME AS TableName, i.name, i.type_desc, p.rows AS RowCounts,
a.total_pages AS TotalPages, a.used_pages AS UsedPages
FROM sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND 
    i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME = 'Customer' and p.index_id > 0


-- pages utilization, here change login and PK
select i.name, s.index_level as level, s.page_count, s.record_count, 
  s.avg_record_size_in_bytes as avg_record_size,
  round(s.avg_page_space_used_in_percent,1) as page_utilization, 
  round(s.avg_fragmentation_in_percent,2) as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'Customer'), NULL, NULL , 'DETAILED') s
join sys.indexes i on s.object_id=i.object_id and s.index_id=i.index_id
where name='PK__Customer__D058768603B87C10'


-- we can preform rebuild now, I guess
alter table Customer rebuild;


-- last clustered table stats for first PDF table
exec PrintPagesClusterTable 'Customer';

-- just for me
SELECT 
t.NAME AS TableName, i.name, i.type_desc, p.rows AS RowCounts,
a.total_pages AS TotalPages, a.used_pages AS UsedPages
FROM sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND 
    i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME = 'Customer' and p.index_id > 0

-- pages utilization
select i.name, s.index_level as level, s.page_count, s.record_count, 
  s.avg_record_size_in_bytes as avg_record_size,
  round(s.avg_page_space_used_in_percent,1) as page_utilization, 
  round(s.avg_fragmentation_in_percent,2) as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'Customer'), NULL, NULL , 'DETAILED') s
join sys.indexes i on s.object_id=i.object_id and s.index_id=i.index_id
where name='PK__Customer__D058768603B87C10'

-- now we need to do projection * on one primary key - point query
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where idcustomer = 12345
option (maxdop 1);

-- now we need to do it for tens of records - range query
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where lName='Èerná' AND fName='Lenka' AND residence='Pøerov'
option (maxdop 1);

-- okay, now we need to create index
CREATE INDEX customer_name_res ON Customer (lname, fname, residence);

-- this is just for check, should give PK and "customer_name_res"
exec PrintIndexes 'Customer'; 

-- once again, again, again, again, again, again, ...
set statistics time on;
set statistics time off;

set statistics io on;
set statistics io off;

set showplan_text on;
set showplan_text off

select *
from customer
where lName='Èerná' AND fName='Lenka' AND residence='Pøerov'
option (maxdop 1);

-- if you get time 0, use this, this absolutely doesn't make sense,
-- uncomment that like line, or lower > 10 number
-- uncommenting like is probably way to go
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
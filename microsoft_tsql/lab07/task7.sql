-- 8.1. 
SELECT count(*)
FROM Customer
where gender = 'f'; -- 149 836

set statistics time on;
set statistics time off;
set statistics io on;
set statistics io off;
set showplan_text on;
set showplan_text off;

SELECT *
FROM Customer
where gender = 'f'
ORDER BY lname , idCustomer
option (maxdop 1); -- 149 836

SELECT *
FROM Customer
WHERE gender = 'f'
ORDER BY lname , idCustomer
OFFSET 0 ROWS FETCH NEXT 100 ROWS ONLY
OPTION (MAXDOP 1); -- 100

SELECT *
FROM Customer
WHERE gender = 'f'
ORDER BY lname , idCustomer
OFFSET 149800 ROWS FETCH NEXT 100 ROWS ONLY
OPTION (MAXDOP 1); --36
.
-- 8.2.
--create clustered table
create table OrderItem_ct (
	idOrder int references "Order"(idOrder) not null, 
	idProduct int references Product(idProduct) not null, 
	unit_price bigint not null,
	quantity int not null,
	primary key (idOrder, idProduct) -- before it was: primary key nonclustered(idOrder, idProduct)
); 

-- insert data into clustered index
insert into dbo.OrderItem_ct
select *
from ProductOrder.dbo.OrderItem;

-- get clustered table stats
exec PrintPagesClusterTable 'OrderItem_ct'; -- exec printpages 'OrderItem_ct', 1;

set statistics time on;
set statistics time off;
set statistics io on;
set statistics io off;
set showplan_text on;
set showplan_text off;

-- query to analyze
SELECT * FROM OrderItem_ct
where unit_price = 6666
OPTION (MAXDOP 1); --102

-- compression none
ALTER TABLE OrderItem_ct REBUILD PARTITION = all
WITH (DATA_COMPRESSION = NONE);

-- compression row
ALTER TABLE OrderItem_ct REBUILD PARTITION = all
WITH (DATA_COMPRESSION = ROW);

-- compression page
ALTER TABLE OrderItem_ct REBUILD PARTITION = all
WITH (DATA_COMPRESSION = PAGE);
-- ProductOrderDb, A database for Physical Database Design
-- SQL Server Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-21

insert into dbo.Customer
select *
from ProductOrder.dbo.Customer;
insert into dbo.Product
select *
from ProductOrder.dbo.Product;
insert into dbo.Store
select *
from ProductOrder.dbo.Store;
insert into dbo.Staff
select *
from ProductOrder.dbo.Staff;
insert into dbo."Order"
select *
from ProductOrder.dbo."Order";
insert into dbo.OrderItem
select *
from ProductOrder.dbo.OrderItem;
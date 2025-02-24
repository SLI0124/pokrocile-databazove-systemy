-- ProductOrderDb, A database for Physical Database Design
-- Oracle Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-21

insert into Customer select * from ProductOrder.Customer;
insert into Product select * from ProductOrder.Product;
insert into Store select * from ProductOrder.Store;
insert into Staff select * from ProductOrder.Staff;
insert into "Order" select * from ProductOrder."Order";
insert into OrderItem select * from ProductOrder.OrderItem;
commit;
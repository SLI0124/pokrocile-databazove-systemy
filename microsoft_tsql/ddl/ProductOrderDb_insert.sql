-- ProductOrderDb, A database for Physical Database Design
-- SQL Server Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-14

EXEC generate_customers;
GO
EXEC generate_products;
GO
EXEC generate_stores;
GO
EXEC generate_staff;
GO
create index staff_idStore_idx on Staff (idStore)
GO
EXEC generate_orders
GO
drop index staff_idStore_idx on Staff;
GO

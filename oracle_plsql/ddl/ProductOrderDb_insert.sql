-- ProductOrderDb, A database for Physical Database Design
-- Oracle Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-14

call generate_customers();

call generate_products();

call generate_stores();

call generate_staff();

create index staff_idStore_idx on Staff (idStore);

call generate_orders();

drop index staff_idStore_idx;
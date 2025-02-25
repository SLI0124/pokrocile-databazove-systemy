-- 2.1.2
-- index_customer
exec PrintIndexes 'Customer';
go
-- index_order
exec PrintIndexes 'Order';
go
-- index_orderitem
exec PrintIndexes 'OrderItem';
go
-- index_product
exec PrintIndexes 'Product';
go
-- index_staff
exec PrintIndexes 'Staff';
go
-- index_store
exec PrintIndexes 'Store'
go

-- 2.1.2
-- Customer
-- index_blocks_customer
exec PrintPagesIndex 'PK__Customer__D0587687B018A16B';

-- heap_blocks_order
exec PrintPagesHeap 'Customer';

-- Order
-- index_blocks_order
exec PrintPagesIndex 'PK__Order__C8AAF6FEB772B1E2';

-- heap_blocks_order
exec PrintPagesHeap 'Order';

-- OrderItem
-- index_blocks_orderitem
exec PrintPagesIndex 'PK__OrderIte__CD4431637FC271FD';

-- heap_blocks_orderitem
exec PrintPagesHeap 'OrderItem';

-- Product
-- index_blocks_product
exec PrintPagesIndex 'PK__Product__5EEC79D0EED0C505';

-- heap_blocks_product
exec PrintPagesHeap 'Product';

-- Staff
-- index_blocks_staff
exec PrintPagesIndex 'PK__Staff__98C886A82049A895';

-- heap_blocks_staff
exec PrintPagesHeap 'Staff';

-- Store
-- index_blocks_store_v1
exec PrintPagesIndex 'PK__Store__A4B61B1120307B18';

-- heap_blocks_store
exec PrintPagesHeap 'Store';

-- 2.2.1
-- Order
-- first, less detailed
select i.name, s.index_depth - 1 as height, sum(s.page_count) as page_count
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'Order'), NULL, NULL, 'DETAILED') s
         join sys.indexes i on s.object_id = i.object_id and s.index_id = i.index_id
where name = 'PK__Order__C8AAF6FEB772B1E2'
group by i.name, s.index_depth

-- second, much more detailed
select s.index_level                              as level,
       s.page_count,
       s.record_count,
       s.avg_record_size_in_bytes                 as avg_record_size,
       round(s.avg_page_space_used_in_percent, 1) as page_utilization,
       round(s.avg_fragmentation_in_percent, 2)   as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'Order'), NULL, NULL, 'DETAILED') s
         join sys.indexes i on s.object_id = i.object_id and s.index_id = i.index_id
where name = 'PK__Order__C8AAF6FEB772B1E2';

-- 2.4.1
-- order item
select s.index_level                              as level,
       s.page_count,
       s.record_count,
       s.avg_record_size_in_bytes                 as avg_record_size,
       round(s.avg_page_space_used_in_percent, 1) as page_utilization,
       round(s.avg_fragmentation_in_percent, 2)   as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'OrderItem'), NULL, NULL, 'DETAILED') s
         join sys.indexes i on s.object_id = i.object_id and s.index_id = i.index_id
where name = 'PK__OrderIte__CD4431637FC271FD';

alter index PK__OrderIte__CD4431637FC271FD on OrderItem rebuild;

select s.index_level                              as level,
       s.page_count,
       s.record_count,
       s.avg_record_size_in_bytes                 as avg_record_size,
       round(s.avg_page_space_used_in_percent, 1) as page_utilization,
       round(s.avg_fragmentation_in_percent, 2)   as avg_frag
from sys.dm_db_index_physical_stats(DB_ID(N'sli0124'), OBJECT_ID(N'OrderItem'), NULL, NULL, 'DETAILED') s
         join sys.indexes i on s.object_id = i.object_id and s.index_id = i.index_id
where name = 'PK__OrderIte__CD4431637FC271FD';
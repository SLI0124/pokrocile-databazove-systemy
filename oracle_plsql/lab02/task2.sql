-- 2.1.1
-- index_customer
select index_name
from USER_INDEXES
where TABLE_NAME = 'CUSTOMER';

-- index_order
select index_name
from USER_INDEXES
where TABLE_NAME = 'Order';

-- index_orderitem
select index_name
from USER_INDEXES
where TABLE_NAME = 'ORDERITEM';

-- index_product
select index_name
from USER_INDEXES
where TABLE_NAME = 'PRODUCT';

-- index_staff
select index_name
from USER_INDEXES
where TABLE_NAME = 'STAFF';

-- index_store
select index_name
from USER_INDEXES
where TABLE_NAME = 'STORE';

-- 2.1.2
-- using user_segments(user_tables) - small output, not usable
-- index_blocks_customer_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'CUSTOMER';

-- index_blocks_order_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'Order';

-- index_blocks_orderitem_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'ORDERITEM';

-- index_blocks_product_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'PRODUCT';

-- index_blocks_staff_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'STAFF';

-- index_blocks_store_v1
select blocks
from USER_SEGMENTS
where SEGMENT_NAME = 'STORE';

-- using dbms_space.unused_space - that is what we want
-- Customer
-- index_blocks_customer_v2a
call PRINTPAGES_UNUSED_SPACE('CUSTOMER', 'SLI0124', 'TABLE');

-- heap_blocks_customer_v2a
call PRINTPAGES('CUSTOMER', 'SLI0124');

-- Order
-- index_blocks_order_v2a
call PRINTPAGES_UNUSED_SPACE('Order', 'SLI0124', 'TABLE');

-- heap_blocks_order_v2a
call PRINTPAGES('Order', 'SLI0124');

-- OrderItem
-- index_blocks_orderitem_v2a
call PRINTPAGES_UNUSED_SPACE('ORDERITEM', 'SLI0124', 'TABLE');

-- heap_blocks_orderitem_v2a
call PRINTPAGES('ORDERITEM', 'SLI0124');

-- Product
-- index_blocks_product_v2a
call PRINTPAGES_UNUSED_SPACE('PRODUCT', 'SLI0124', 'TABLE');

-- heap_blocks_product_v2a
call PRINTPAGES('PRODUCT', 'SLI0124');

-- Staff
-- index_blocks_staff_v2a
call PRINTPAGES_UNUSED_SPACE('STAFF', 'SLI0124', 'TABLE');

-- heap_blocks_staff_v2a
call PRINTPAGES('STAFF', 'SLI0124');

-- Store
-- index_blocks_store_v2a
call PRINTPAGES_UNUSED_SPACE('STORE', 'SLI0124', 'TABLE');

-- heap_blocks_store_v2a
call PRINTPAGES('STORE', 'SLI0124');

-- using dbms_space.space_usage - different output, not usable
-- index_blocks_customer_v2b
call PRINTPAGES_SPACE_USAGE('CUSTOMER', 'SLI0124', 'TABLE');

-- index_blocks_order_v2b
call PRINTPAGES_SPACE_USAGE('Order', 'SLI0124', 'TABLE');

-- index_blocks_orderitem_v2b
call PRINTPAGES_SPACE_USAGE('ORDERITEM', 'SLI0124', 'TABLE');

-- index_blocks_product_v2b
call PRINTPAGES_SPACE_USAGE('PRODUCT', 'SLI0124', 'TABLE');

-- index_blocks_staff_v2b
call PRINTPAGES_SPACE_USAGE('STAFF', 'SLI0124', 'TABLE');

-- index_blocks_store_v2b
call PRINTPAGES_SPACE_USAGE('STORE', 'SLI0124', 'TABLE');

-- 2.2.1.
-- Order
ANALYZE INDEX SYS_C0020808 VALIDATE STRUCTURE;

select height-1 as h, blocks, lf_blks as leaf_pages, br_blks as inner_pages, lf_rows as leaf_items,
       br_rows as inner_items, pct_used
from index_stats where name='SYS_C0020808';

-- 2.3.1.
CREATE INDEX IDX_CUSTOMER_LNAME ON CUSTOMER (lName);

ANALYZE INDEX IDX_CUSTOMER_LNAME VALIDATE STRUCTURE;

-- index_customer_lname
select height-1 as h, blocks, lf_blks as leaf_pages, br_blks as inner_pages, lf_rows as leaf_items,
       br_rows as inner_items, pct_used
from index_stats where name='IDX_CUSTOMER_LNAME';

ANALYZE INDEX SYS_C0020787 VALIDATE STRUCTURE;

-- index_customer_primary_key
select height-1 as h, blocks, lf_blks as leaf_pages, br_blks as inner_pages, lf_rows as leaf_items,
       br_rows as inner_items, pct_used
from index_stats where name='SYS_C0020787';

-- heap_customer
call PRINTPAGES('CUSTOMER', 'SLI0124');

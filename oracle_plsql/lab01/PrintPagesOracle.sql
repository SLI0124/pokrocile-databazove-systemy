select blocks from user_segments
where segment_name = 'CUSTOMER';

select blocks, bytes/1024/1024 as MB from user_segments
where segment_name = 'CUSTOMER';

select segment_type, sum(blocks) "Total Blocks", sum(bytes/1024/1024) "MB"
from user_segments
where segment_name in ('CUSTOMER', 'STAFF', 'Order', 'ORDERITEM', 'PRODUCT', 'STORE')
group by segment_type;

select table_name,blocks, empty_blocks,pct_free,pct_used from user_tables
where table_name='CUSTOMER';

create or replace procedure PrintPages(p_table_name varchar, p_user_name varchar)
as
   blocks           number;
   bytes            number;
   unused_blocks    number;
   unused_bytes     number;
   expired_blocks   number;
   expired_bytes    number;
   unexpired_blocks number;
   unexpired_bytes  number;
   mega number := 1024.0 * 1024.0;
begin
  dbms_space.unused_space(p_user_name, p_table_name, 'TABLE', blocks, bytes, unused_blocks,
    unused_bytes, expired_blocks, expired_bytes, unexpired_blocks, unexpired_bytes);

  dbms_output.put_line('blocks: ' || blocks);
  dbms_output.put_line('size (MB): ' || (bytes / mega));
  dbms_output.put_line('used_blocks: ' || (blocks - unused_blocks));
  dbms_output.put_line('size used (MB): ' || ((bytes / mega) - (unused_bytes / mega)));
  dbms_output.put_line('unused_blocks: ' || unused_blocks);
  dbms_output.put_line('size unused (MB): ' || (unused_bytes / mega));
end;
select index_name from user_indexes
where table_name='CUSTOMER';

---------------------------------------------------

select blocks from user_segments
where segment_name = 'CUSTOMER';

select blocks from user_segments
where segment_name = 'SYS_C0020201';

---------------------------------------------------

SELECT segment_type, blocks, bytes / 1024 / 1024 FROM user_segments
WHERE segment_name='CUSTOMER';

SELECT blocks FROM user_tables
WHERE table_name='CUSTOMER';

SELECT segment_type, blocks, bytes / 1024 / 1024
FROM user_segments
WHERE segment_name='SYS_C00552552';

---------------------------------------------------

create or replace procedure PrintPages_space_usage(p_table_name varchar, p_user_name varchar, p_type varchar)
as
   unformatted_blocks NUMBER;
   unformatted_bytes  NUMBER;
   fs1_blocks         NUMBER;
   fs1_bytes          NUMBER;
   fs2_blocks         NUMBER;
   fs2_bytes          NUMBER;
   fs3_blocks         NUMBER;
   fs3_bytes          NUMBER;
   fs4_blocks         NUMBER;
   fs4_bytes          NUMBER;
   full_blocks        NUMBER;
   full_bytes         NUMBER;
begin
  dbms_space.space_usage(p_user_name, p_table_name, p_type, unformatted_blocks, unformatted_bytes,
   fs1_blocks, fs1_bytes, fs2_blocks, fs2_bytes, fs3_blocks, fs3_bytes, fs4_blocks, fs4_bytes,
   full_blocks, full_bytes, null);

  dbms_output.put_line('unformatted_blocks: ' || unformatted_blocks);
  dbms_output.put_line('fs1_blocks (0 to 25% free space): ' || fs1_blocks);
  dbms_output.put_line('fs2_blocks (25 to 50% free space): ' || fs2_blocks);
  dbms_output.put_line('fs3_blocks (50 to 75% free space): ' || fs3_blocks);
  dbms_output.put_line('fs4_blocks (75 to 100% free space): ' || fs4_blocks);
  dbms_output.put_line('full_blocks: ' || full_blocks);
end;

-----------------------------------

create or replace procedure PrintPages_unused_space(p_table_name varchar, p_user_name varchar, p_type varchar)
as
   free_blocks number;
   blocks      number;
   bytes       number;
   unused_blocks    number;
   unused_bytes     number;
   expired_blocks   number;
   expired_bytes    number;
   unexpired_blocks number;
   unexpired_bytes  number;
   mega number := 1024.0 * 1024.0;
begin
  -- dbms_space.free_blocks(p_user_name, p_table_name, p_type, 0, free_blocks);
  dbms_space.unused_space(p_user_name, p_table_name, p_type, blocks, bytes, unused_blocks,
    unused_bytes, expired_blocks, expired_bytes, unexpired_blocks, unexpired_bytes);

  dbms_output.put_line('blocks:        ' || blocks || ',' || CHR(9) || ' size (MB): ' || (bytes / mega));
  -- dbms_output.put_line('free blocks:        ' || free_blocks || ',' || CHR(9) || ' size (MB): ' || ((free_blocks * 8192) / mega));
  dbms_output.put_line('used_blocks:   ' || (blocks - unused_blocks) ||  ',' || CHR(9) ||  ' size (MB): ' || ((bytes / mega) - (unused_bytes / mega)));
  dbms_output.put_line('unused_blocks: ' || unused_blocks ||  ',' || CHR(9) || ' size (MB): ' || (unused_bytes / mega));
  dbms_output.put_line('expired_blocks: ' || expired_blocks ||  ',' || CHR(9) || ' unexpired_blocks: ' || unexpired_blocks);
end;

---------------------------------------------------

call PrintPages_unused_space('CUSTOMER', 'KRA28', 'TABLE');
call PrintPages_space_usage('CUSTOMER', 'KRA28', 'TABLE');

call PrintPages_unused_space('SYS_C00552552', 'KRA28', 'INDEX');
call PrintPages_space_usage('SYS_C00552552', 'KRA28', 'INDEX');

---------------------------------------------------

col index_name for a15;

select index_name, blevel, leaf_blocks
from user_indexes where table_name='CUSTOMER';

desc user_indexes;

-------------------------------------

ANALYZE INDEX SYS_C0020201 VALIDATE STRUCTURE;

select height-1 as h, blocks, lf_blks as leaf_pages, br_blks as inner_pages, lf_rows as leaf_items,
       br_rows as inner_items, pct_used
from index_stats where name='SYS_C0020201';

alter index SYS_C0020201 shrink space;
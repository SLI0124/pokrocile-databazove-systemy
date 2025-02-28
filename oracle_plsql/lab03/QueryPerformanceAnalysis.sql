col username format a10;
col sql_text format a30;

select executions as executions,
       buffer_gets/executions as buffer_gets,
       (cpu_time/executions)/1000.0 as cpu_time_ms,
       (elapsed_time/executions)/1000.0 as elapsed_time_ms,
       rows_processed/executions as rows_processed,
       du.username, sql_text
from v$sql
         inner join dba_users du on du.user_id=parsing_user_id
where sql_id='7c0zn2r2hw8y7' and plan_hash_value=2844954298;

-----------------------

create or replace procedure PrintQueryStat(p_sqlId varchar2, p_planHash int)
as
begin
  -- report the statistics of the query processing
for rec in (
    select executions as executions,
      buffer_gets/executions as buffer_gets,
      (cpu_time/executions)/1000.0 as cpu_time_ms,
      (elapsed_time/executions)/1000.0 as elapsed_time_ms,
      rows_processed/executions as rows_processed,
      du.username, sql_text
    from v$sql
    inner join dba_users du on du.user_id=parsing_user_id
    where sql_id=p_sqlId and plan_hash_value=p_planHash
  )
  loop
    dbms_output.put_line('---- Query Processing Statistics ----');
    dbms_output.put_line('executions: ' || chr(9) || rec.executions);
    dbms_output.put_line('buffer gets: ' || chr(9) || rec.buffer_gets);
    dbms_output.put_line('cpu_time_ms: ' || chr(9) || rec.cpu_time_ms);
    dbms_output.put_line('elapsed_time_ms: ' || chr(9) || rec.elapsed_time_ms);
    dbms_output.put_line('rows_processed: ' || chr(9) || rec.rows_processed);
    dbms_output.put_line('username: ' || chr(9) || rec.username);
    dbms_output.put_line('query: ' || chr(9) || rec.sql_text);
end loop;
end;

------------------------------------

explain plan for select * from Customer
                 where birthday = TO_DATE('01.01.2000', 'DD.MM.YYYY');

select * from table(dbms_xplan.display);
-- Plan hash value: 2844954298

---------------------------------------------------

set feedback on SQL_ID;

select * from Customer
where fname = 'Jana' and lname = 'Novotná' and residence = 'České Budějovice';

set feedback off SQL_ID;

explain plan for select * from Customer
                 where fname = 'Jana' and lname = 'Novotná' and residence = 'České Budějovice';

select * from table(dbms_xplan.display);

exec PrintQueryStat('1qbvrc9axd1wq', 2844954298);


-- ProductOrderDb, A database for Physical Database Design
-- Oracle Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-14

create or replace procedure generate_customers
is
  rec_count_const constant int := 300000;
  rec_count int;
  
  type fname_male_array is varray(15) of varchar(20);
  fname_maleArray fname_male_array := fname_male_array('Jiří', 'Jan', 'Petr', 'Josef', 'Pavel', 'Martin', 'Tomáš', 'Jaroslav', 'Miroslav', 'Zdeněk', 'Václav', 
    'Michal', 'František', 'Jakub', 'Milan');  
  cnt_fname_male number := fname_maleArray.COUNT;
  
  type fname_female_array is varray(10) of varchar(20);
  fname_femaleArray fname_female_array := fname_female_array('Jana', 'Marie', 'Eva', 'Hana', 'Anna', 'Lenka', 'Kateřina', 'Lucie', 'Věra', 'Alena');
  cnt_fname_female number := fname_femaleArray.COUNT;
  
  type lname_male_array is varray(12) of varchar(30);
  lname_maleArray lname_male_array := lname_male_array('Novák', 'Svoboda', 'Novotný', 'Dvořák', 'Černý', 'Procházka', 'Kučera', 'Veselý', 'Krejčí', 'Horák', 
    'Němec', 'Marek');
  cnt_lname_male number := lname_maleArray.COUNT;

  type lname_female_array is varray(13) of varchar(30);
  lname_femaleArray lname_female_array := lname_female_array('Nováková', 'Svobodová', 'Novotná', 'Dvořáková', 'Černá', 'Procházková', 'Kučerová', 'Veselá', 
    'Horáková', 'Němcová', 'Marková', 'Pokorná', 'Pospíšilová');
  cnt_lname_female number := lname_femaleArray.COUNT;

  type residence_array is varray(20) of varchar(20);
  residenceArray residence_array := residence_array('Praha', 'Brno', 'Ostrava', 'Plzeň', 'Liberec', 'Olomouc', 'České Budějovice', 'Ústí nad Label', 'Karlovy Vary',
    'Zlín', 'Děčín', 'Beroun', 'Pardubice', 'Hradec Králové', 'Šumperk', 'Bohumín', 'Znojmo', 'Prostějov', 'Přerov', 'Jihlava');
  cnt_residence number := residenceArray.COUNT;
  
  min_age_month constant int := 216; -- 18y
  max_age_over_min constant int := 960; -- 80y => max age is 98y
  
  age_month int;
  crn_date date;
  
  cst Customer%ROWTYPE;
  
  code number;
  errm varchar(64);  
  
  time_start NUMBER := dbms_utility.get_time();

begin
  dbms_output.put_line('Start generating ' || rec_count_const || ' records into table Customer ...');

  dbms_output.put_line('#fname_male: ' || cnt_fname_male);
  dbms_output.put_line('#fname_female: ' || cnt_fname_female);
  dbms_output.put_line('#lname_male: ' || cnt_lname_male);
  dbms_output.put_line('#lname_female: ' || cnt_lname_female);
  dbms_output.put_line('#residence: ' || cnt_residence);

select trunc(sysdate) into crn_date from dual;

dbms_output.put_line('crn_date: ' || TO_CHAR(crn_date, 'MM/DD/YY HH24:MI:SS'));

for i IN 1..rec_count_const
  loop
    cst.idCustomer := i;

    if (dbms_random.value(0,1) = 0) then
      cst.gender := 'm';
      cst.fname := fname_maleArray(dbms_random.value(1,cnt_fname_male));
      cst.lname := lname_maleArray(dbms_random.value(1,cnt_lname_male));
else
      cst.gender := 'f';
      cst.fname := fname_femaleArray(dbms_random.value(1,cnt_fname_female));
      cst.lname := lname_femaleArray(dbms_random.value(1,cnt_lname_female));
end if;

    cst.residence := residenceArray(dbms_random.value(1,cnt_residence));

    -- generate birthday
    age_month := min_age_month + dbms_random.value(1,max_age_over_min);
    cst.birthday := add_months(sysdate, -age_month);
    -- change the day of the birthday
    cst.birthday := trunc(cst.birthday - dbms_random.value(1,31));

    -- dbms_output.put_line('#' || cst.idCustomer || ': ' || 'fname: ' || cst.fname || ', lname: ' || cst.lname || ', residence: ' || cst.residence || ', birthdate: ' || TO_CHAR(cst.birthday, 'DD.MM.YYYY')  || ', gender: ' || cst.gender);
insert into Customer values cst;
end loop;

commit;

dbms_output.put_line('Commit.');
select count(*) into rec_count from Customer;
dbms_output.put_line('Table Customer includes ' || rec_count || ' records.');
  dbms_output.put_line('Generating time : ' || ((dbms_utility.get_time() - time_start) / 100) || 's');

exception
  when others then
    code := sqlcode;
    errm := substr(SQLERRM, 1, 64);
    dbms_output.put_line(code || ' ' || errm);

rollback;
dbms_output.put_line('Rollback.');
end;
/

----------------------------------------------------------------

create or replace procedure generate_products
is
  rec_count_const constant int := 100000;
  rec_count int;
  product_name_min constant int := 1;
  product_name_max constant int := 50;

  type producer_array is varray(30) of varchar(30);
  producerArray producer_array := producer_array('Shimano', 'Specialized', 'Superior', 'Sram', 'Samsung', 'Apple', 'Dell', 'LG', 'Bosch', 'Siemens', 'AEG', 'Mora',
    'Eta', 'Volkswagen', 'Škoda', 'Tatra', 'Peugot', 'Opel', 'Fiat', 'Lockheed Martin', 'Excalibur', 'Česká zbrojovka', 'Rheinmetall', 'Saab', 'Boeing', 'Airbus',
    'Narex', 'Hilti', 'John Deere', 'Zetor');
  cnt_producer number := producerArray.COUNT;

  type product_array is varray(31) of varchar(30);
  type product_minprice_array is varray(31) of number;
  type product_maxprice_array is varray(31) of number;
  productArray product_array := product_array('Auto', 'Tank', 'Telefon', 'Tablet', 'Notebook', 'Desktop', 'Server', 'Diskové pole', 'HDD', 'SDD', 'Puška',
    'Pistol', 'Stíhací letoun', 'Bombardér', 'Horské kolo', 'Silniční kolo', 'Odpružená vidlice', 'Přehazovačka, MTB', 'Pračka', 'Lednička', 'Myčka',
    'Sušička', 'Varná konvice', 'Mikrovlná trouba', 'Mixér', 'Vrtací kladivo', 'Bourací kladivo', 'Svářečka', 'Tepelné čerpadlo', 'Traktor', 'Sněžná rolba');
  product_minpriceArray product_minprice_array := product_minprice_array(600000, 20000000, 500, 500, 5000, 5000, 150000, 150000, 300, 300, 10000,
    10000, 1200000000, 1200000000, 10000, 10000, 3000, 1000, 5000, 5000, 5000,
    5000, 1000, 3000, 1000, 7000, 7000, 7000, 10000, 1000000, 1000000);
  product_maxpriceArray product_maxprice_array := product_maxprice_array(2000000, 25000000, 40000, 40000, 70000, 70000, 1000000, 1000000, 35000, 35000, 100000,
    100000, 2000000000, 2000000000, 200000, 200000, 30000, 10000, 50000, 50000, 50000,
    50000, 5000, 10000, 10000, 70000, 70000, 70000, 500000, 5000000, 5000000);

  cnt_product number := productArray.COUNT;
  product_num number;
  prod Product%ROWTYPE;

  code number;
  errm varchar(64);

  time_start NUMBER := dbms_utility.get_time();

begin
  dbms_output.put_line('Start generating ' || rec_count_const || ' records into table Product ...');

  dbms_output.put_line('#producer: ' || cnt_producer);
  dbms_output.put_line('#product: ' || cnt_product);

for i IN 1..rec_count_const
  loop
    prod.idProduct := i;
    prod.producer := producerArray(dbms_random.value(1,cnt_producer));
    prod.description := null;

    -- generate product unit price and name
    product_num := dbms_random.value(1,cnt_product);
    prod.unit_price := dbms_random.value(product_minpriceArray(product_num), product_maxpriceArray(product_num));
    prod.name := productArray(product_num) || ' ' || trunc(dbms_random.value(product_name_min, product_name_max));

insert into Product values prod;
end loop;

commit;

dbms_output.put_line('Commit.');
select count(*) into rec_count from Product;
dbms_output.put_line('Table Product includes ' || rec_count || ' records.');
  dbms_output.put_line('Generating time : ' || ((dbms_utility.get_time() - time_start) / 100) || 's');

exception
  when others then
    code := sqlcode;
    errm := substr(SQLERRM, 1, 64);
    dbms_output.put_line(code || ' ' || errm);

rollback;
dbms_output.put_line('Rollback.');
end;
/

----------------------------------------------------------------

create or replace procedure generate_stores
is
  rec_count_const constant int := 1000;
  rec_count int;
  store_name_min constant int := 1;
  store_name_max constant int := 50;

  type store_name_array is varray(11) of varchar(30);
  store_nameArray store_name_array := store_name_array('Alza', 'Mall', 'T.S.BOHEMIA', 'Datart', 'Globus', 'Tesco', 'Euronics', 'Okay', 'Comfor', 'CZC', 'Hornbach');
  cnt_store_name number := store_nameArray.COUNT;

  type residence_array is varray(20) of varchar(20);
  residenceArray residence_array := residence_array('Praha', 'Brno', 'Ostrava', 'Plzeň', 'Liberec', 'Olomouc', 'České Budějovice', 'Ústí nad Label', 'Karlovy Vary',
    'Zlín', 'Děčín', 'Beroun', 'Pardubice', 'Hradec Králové', 'Šumperk', 'Bohumín', 'Znojmo', 'Prostějov', 'Přerov', 'Jihlava');
  cnt_residence number := residenceArray.COUNT;

  str Store%ROWTYPE;

  code number;
  errm varchar(64);

  time_start NUMBER := dbms_utility.get_time();

begin
  dbms_output.put_line('Start generating ' || rec_count_const || ' records into table Store ...');

  dbms_output.put_line('#store_name: ' || cnt_store_name);
  dbms_output.put_line('#residence: ' || cnt_residence);

for i IN 1..rec_count_const
  loop
    str.idStore := i;
    str.name := store_nameArray(dbms_random.value(1,cnt_store_name));
    str.name := str.name || ' ' || trunc(dbms_random.value(store_name_min, store_name_max));
    str.residence := residenceArray(dbms_random.value(1,cnt_residence));

    -- dbms_output.put_line('#' || str.idStore || ': name: ' || str.name || ', residence: ' || str.residence);
insert into Store values str;
end loop;

commit;

dbms_output.put_line('Commit.');
select count(*) into rec_count from Store;
dbms_output.put_line('Table Store includes ' || rec_count || ' records.');
  dbms_output.put_line('Generating time : ' || ((dbms_utility.get_time() - time_start) / 100) || 's');

exception
  when others then
    code := sqlcode;
    errm := substr(SQLERRM, 1, 64);
    dbms_output.put_line(code || ' ' || errm);

rollback;
dbms_output.put_line('Rollback.');
end;
/

----------------------------------------------------------------

create or replace procedure generate_staff
is
  rec_count_const constant int := 10000;
  max_staff_num constant int := 9999;
  rec_count int;
  store_count int;

  type fname_male_array is varray(15) of varchar(20);
  fname_maleArray fname_male_array := fname_male_array('Jiří', 'Jan', 'Petr', 'Josef', 'Pavel', 'Martin', 'Tomáš', 'Jaroslav', 'Miroslav', 'Zdeněk', 'Václav',
    'Michal', 'František', 'Jakub', 'Milan');
  cnt_fname_male number := fname_maleArray.COUNT;

  type fname_female_array is varray(10) of varchar(20);
  fname_femaleArray fname_female_array := fname_female_array('Jana', 'Marie', 'Eva', 'Hana', 'Anna', 'Lenka', 'Kateřina', 'Lucie', 'Věra', 'Alena');
  cnt_fname_female number := fname_femaleArray.COUNT;

  type lname_male_array is varray(12) of varchar(30);
  lname_maleArray lname_male_array := lname_male_array('Novák', 'Svoboda', 'Novotný', 'Dvořák', 'Černý', 'Procházka', 'Kučera', 'Veselý', 'Krejčí', 'Horák',
    'Němec', 'Marek');
  cnt_lname_male number := lname_maleArray.COUNT;

  type lname_female_array is varray(13) of varchar(30);
  lname_femaleArray lname_female_array := lname_female_array('Nováková', 'Svobodová', 'Novotná', 'Dvořáková', 'Černá', 'Procházková', 'Kučerová', 'Veselá',
    'Horáková', 'Němcová', 'Marková', 'Pokorná', 'Pospíšilová');
  cnt_lname_female number := lname_femaleArray.COUNT;

  type residence_array is varray(20) of varchar(20);
  residenceArray residence_array := residence_array('Praha', 'Brno', 'Ostrava', 'Plzeň', 'Liberec', 'Olomouc', 'České Budějovice', 'Ústí nad Label', 'Karlovy Vary',
    'Zlín', 'Děčín', 'Beroun', 'Pardubice', 'Hradec Králové', 'Šumperk', 'Bohumín', 'Znojmo', 'Prostějov', 'Přerov', 'Jihlava');
  cnt_residence number := residenceArray.COUNT;

  type start_contract_array is varray(10) of date;
  start_contractArray start_contract_array := start_contract_array(to_date('2016-01-01', 'YYYY-MM-DD'),
    to_date('2017-01-01', 'YYYY-MM-DD'), to_date('2018-01-01', 'YYYY-MM-DD'), to_date('2019-01-01', 'YYYY-MM-DD'),
    to_date('2020-01-01', 'YYYY-MM-DD'), to_date('2021-01-01', 'YYYY-MM-DD'), to_date('2022-01-01', 'YYYY-MM-DD'),
    to_date('2023-01-01', 'YYYY-MM-DD'), to_date('2024-01-01', 'YYYY-MM-DD'), to_date('2025-01-01', 'YYYY-MM-DD'));
  cnt_start_contract number := start_contractArray.COUNT;

  min_age_month constant int := 216; -- 18y
  max_age_over_min constant int := 960; -- 80y => max age is 98y

  v_cntIds int;
  age_month int;
  crn_date date;
  stf Staff%ROWTYPE;
  time_start NUMBER := dbms_utility.get_time();

begin
select count(*) into store_count from Store;

dbms_output.put_line('Start generating ' || rec_count_const || ' records into table Staff ...');

  dbms_output.put_line('#fname_male: ' || cnt_fname_male);
  dbms_output.put_line('#fname_female: ' || cnt_fname_female);
  dbms_output.put_line('#lname_male: ' || cnt_lname_male);
  dbms_output.put_line('#lname_female: ' || cnt_lname_female);
  dbms_output.put_line('#residence: ' || cnt_residence);
  dbms_output.put_line('#store_count: ' || store_count);
  dbms_output.put_line('#max_staff_num: ' || max_staff_num);
  dbms_output.put_line('#cnt_start_contract: ' || cnt_start_contract);

select trunc(sysdate) into crn_date from dual;

dbms_output.put_line('crn_date: ' || TO_CHAR(crn_date, 'MM/DD/YY HH24:MI:SS'));

for i IN 1..rec_count_const
  loop
    if (dbms_random.value(0,1) = 0) then
      stf.gender := 'm';
      stf.fname := fname_maleArray(dbms_random.value(1,cnt_fname_male));
      stf.lname := lname_maleArray(dbms_random.value(1,cnt_lname_male));
else
      stf.gender := 'f';
      stf.fname := fname_femaleArray(dbms_random.value(1,cnt_fname_female));
      stf.lname := lname_femaleArray(dbms_random.value(1,cnt_lname_female));
end if;

    stf.residence := residenceArray(dbms_random.value(1,cnt_residence));

    -- generate id of the staff like nem135 for Němec
    v_cntIds := 0;
for i IN 1..max_staff_num
    loop
      stf.idStaff := lower(substr(stf.fname,1,1) || translate(substr(stf.lname,1,2), 'Ččě', 'cce')) || i;
select count(*) into v_cntIds from Staff where idStaff = stf.idStaff;
exit when v_cntIds = 0;
end loop;

    stf.idStore := dbms_random.value(1, store_count);

    -- generate birthday
    age_month := min_age_month + dbms_random.value(1,max_age_over_min);
    stf.birthday := add_months(sysdate, -age_month);
    -- change the day of the birthday
    stf.birthday := trunc(stf.birthday - dbms_random.value(1,31));
    stf.start_contract := start_contractArray(dbms_random.value(1,cnt_start_contract));

    -- dbms_output.put_line('#' || stf.idStaff || ': ' || 'fname: ' || stf.fname || ', lname: ' ||
    --  stf.lname || ', residence: ' || stf.residence || ', birthdate: ' || TO_CHAR(stf.birthday, 'DD.MM.YYYY')  ||
    --  ', gender: ' || stf.gender || ', idStore: ' || stf.idStore || ', start_contract: ' || TO_CHAR(stf.start_contract, 'DD.MM.YYYY'));
insert into Staff values stf;
end loop;

commit;

dbms_output.put_line('Commit.');
select count(*) into rec_count from Staff;
dbms_output.put_line('Table Staff includes ' || rec_count || ' records.');
  dbms_output.put_line('Generating time : ' || ((dbms_utility.get_time() - time_start) / 100) || 's');

exception
  when others then
    dbms_Output.put_line(dbms_utility.format_error_stack());
rollback;
dbms_output.put_line('Rollback.');
end;
/

----------------------------------------------------------------

create or replace procedure generate_orders
is
  rec_count_const constant int := 5000000; -- the number of records in the table OrderItem
  order_rec_count int;
  orderItem_rec_count int := 1;

  min_age_month constant int := 216;  -- 18y
  item_count_max constant int := 20;
  quantity_max constant int := 10;

  -- type idProductArrayType is table of Product.idProduct%type;
  idProductArray idProductArrayType := idProductArrayType();

  type productArrayType is table of Product%rowtype;
  productArray productArrayType := productArrayType();

  type orderItemArrayType is table of OrderItem%rowtype;
  orderItemArray orderItemArrayType := orderItemArrayType();

  -- the count of records from the table
  customer_count int;
  store_count int;
  product_count int;

  -- for randomly generated values
  item_count_num int;
  product_num int;
  price_num int;
  opr_num int;

  item_count int;
  time_month_count int;
  orderItem_unique int;

  customer_from date;
  crn_date date;

  time_start NUMBER := dbms_utility.get_time();

  time_tmp_start NUMBER;
  time_tmp_end NUMBER;
  time_tmp_period NUMBER := 0;

  ord "Order"%rowtype;
  cust Customer%rowtype;
  prod Product%rowtype;
  otm OrderItem%rowtype;

  v_staff_cnt int;
  v_staff_rnd int;

begin
  dbms_output.put_line('Start generating ' || rec_count_const || ' records into table OrderItem ...');

  -- execute immediate 'create private temporary table ora$ptt_staff as select * from Staff';
  -- no improvement of private temporary table
  -- moreover, the index Staff(idStore) speed up the performance 2x

select count(*) into customer_count from Customer;
select count(*) into store_count from Store;
select count(*) into product_count from Product;

select trunc(sysdate) into crn_date from dual;

ord.idOrder := 1;
  loop
    -- time_tmp_start := dbms_utility.get_time();
    -- time_tmp_end := dbms_utility.get_time();
    -- time_tmp_period := time_tmp_period + time_tmp_end - time_tmp_start;

    -- 16%
    -- select a customer
select * into cust from Customer where idCustomer = trunc(dbms_random.value(1,customer_count));
ord.idCustomer := cust.idCustomer;
    ord.order_status := null;

    -- generate the time of the order
    customer_from := add_months(cust.birthday, min_age_month);  -- add the min age of order
    time_month_count := months_between(crn_date, customer_from);
    ord.order_datetime := add_months(customer_from, dbms_random.value(1,time_month_count));

    -- select the store of the order
    ord.idStore := trunc(dbms_random.value(1,store_count));

    -- select a random staff of the store
    -- execute immediate 'select count(*) from ora$ptt_staff where idStore=:x'
    --  into v_staff_cnt using ord.idStore;
select count(*) into v_staff_cnt from Staff where idStore=ord.idStore;

v_staff_rnd := trunc(dbms_random.value(1,v_staff_cnt));

select idStaff into ord.idStaff from
    (
        select
            rank() over (
	      order by idStaff desc
        ) ro,
                idStaff
        from Staff
        where idStore=ord.idStore
    )
where ro = v_staff_rnd;

/*
    execute immediate 'select idStaff from ' ||
    '( ' ||
      'select ' ||
        'rank() over ( ' ||
	      'order by idStaff desc ' ||
        ') ro, ' ||
        'idStaff ' ||
      'from ora$ptt_staff ' ||
      'where idStore=:1 ' ||
    ') ' ||
    'where ro = :2' into ord.idStaff using ord.idStore, v_staff_rnd;
    */

-- 14%
insert into "Order" values ord;  -- and finaly insert the record

-- 1.5%
-- add items to the order
item_count_num := trunc(dbms_random.value(1,item_count_max));
    item_count := 1;
    otm.idOrder := ord.idOrder;

    idProductArray.delete();
    idProductArray.extend(item_count_num);

    -- generate idProduct for item_count_num records
    loop
      -- 0.3%
      -- select a product
product_num := dbms_random.value(1,product_count);

      -- check the uniqueness of the (idOrder, idProduct)
      -- check the previously generated idProduct in the array instead of the query:
      -- select count(*) into orderItem_unique from OrderItem where idOrder=otm.idOrder and idProduct=product_num;
      orderItem_unique := 0;

for i IN 1..item_count
      loop
        if idProductArray(i) = product_num then
          orderItem_unique := 1;
          exit;
end if;
end loop;

      if (orderItem_unique = 0) then
        idProductArray(item_count) := product_num; -- set idProduct in the array
        item_count := item_count + 1;
end if;
      exit when item_count > item_count_num;
end loop;

    -- use bulk collect instead of item_count queries
    -- select * into prod from Product where idProduct = product_num;
    -- 29%
    productArray.delete();
select * bulk collect into productArray
from Product where idProduct in (select * from table(idProductArray));

-- Set the array of OrderItem
-- 9%
orderItemArray.delete();
    orderItemArray.extend(item_count_num);

for i IN 1..item_count_num
    loop
        prod := productArray(i);

        -- set idProduct
        otm.idProduct := prod.idProduct;

        -- set the quantity
        otm.quantity := dbms_random.value(1,quantity_max);

        -- set the unit price, +/- 0.1 of unit_price of the product
        price_num := dbms_random.value(1, prod.unit_price / 10);
        opr_num := dbms_random.value(0,1);
        if (opr_num = 0) then
          otm.unit_price := prod.unit_price + price_num;
else
          otm.unit_price := prod.unit_price - price_num;
end if;

        orderItemArray(i) := otm;
        orderItem_rec_count := orderItem_rec_count + 1;
end loop;

    -- bulk insert operation is used instead of insert-by-insert
    -- insert into OrderItem values otm;
    -- 25%
    forall i in 1 .. item_count_num
      insert into OrderItem values orderItemArray(i);

    exit when orderItem_rec_count >= rec_count_const;
    ord.idOrder := ord.idOrder + 1;
end loop;

commit;

dbms_output.put_line('Commit.');
select count(*) into order_rec_count from "Order";
dbms_output.put_line('Table Order includes ' || order_rec_count || ' records.');
select count(*) into orderItem_rec_count from OrderItem;
dbms_output.put_line('Table OrderItem includes ' || orderItem_rec_count || ' records.');
  dbms_output.put_line('Generating time : ' || ((dbms_utility.get_time() - time_start) / 100) || 's');
  -- dbms_output.put_line('Tmp time : ' || (time_tmp_period / 100) || 's');
exception
  when others then
    dbms_Output.put_line(dbms_utility.format_error_stack());
rollback;
dbms_output.put_line('Rollback.');
end;
/
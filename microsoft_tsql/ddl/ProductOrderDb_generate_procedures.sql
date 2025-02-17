-- ProductOrderDb, A database for Physical Database Design
-- SQL Server Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-14

CREATE OR ALTER PROCEDURE generate_customers AS
BEGIN
SET NOCOUNT ON
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @gtt_fname_male TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_fname_female TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_lname_male TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_lname_female TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_residence TABLE(id INT, name VARCHAR(40))

	DECLARE @rec_count int = 300000
	DECLARE @min_age_month int = 216; -- 18y
	DECLARE @max_age_over_min int = 960; -- 80y => max age is 98y

	DECLARE @cnt_fname_male int
	DECLARE @cnt_fname_female int
	DECLARE @cnt_lname_male int
	DECLARE @cnt_lname_female int
	DECLARE @cnt_residence int
	DECLARE @crn_date date

	-- Prepare the table variables
	INSERT INTO @gtt_fname_male
	VALUES (0, 'Jiří'),	(1, 'Jan'),	(2, 'Petr'), (3, 'Josef'), (4, 'Pavel'), (5, 'Martin'),
	  (6, 'Tomáš'), (7, 'Jaroslav'), (8, 'Miroslav'),	(9, 'Zdeněk'), (10, 'Václav'),
	  (11, 'Michal'), (12, 'František'), (13, 'Jakub'), (14, 'Milan')

	insert into @gtt_fname_female
	values (0, 'Jana'), (1, 'Marie'), (2, 'Eva'), (3, 'Hana'), (4, 'Anna'), (5, 'Lenka'),
	  (6, 'Kateřina'), (7, 'Lucie'), (8, 'Věra'), (9, 'Alena')

	insert into @gtt_lname_male
	values (0, 'Novák'), (1, 'Svoboda'), (2, 'Novotný'), (3, 'Dvořák'), (4, 'Černý'), (5, 'Procházka'),
	  (6, 'Kučera'), (7, 'Veselý'), (8, 'Krejčí'), (9, 'Horák'), (10, 'Němec'), (11, 'Marek')

	insert into @gtt_lname_female
	values (0, 'Nováková'), (1, 'Svobodová'), (2, 'Novotná'), (3, 'Dvořáková'), (4, 'Černá'),
	  (5, 'Procházková'), (6, 'Kučerová'), (7, 'Veselá'), (8, 'Horáková'), (9, 'Němcová'),
	  (10, 'Marková'), (11, 'Pokorná'), (12, 'Pospíšilová')

	insert into @gtt_residence
	values (0, 'Praha'), (1, 'Brno'), (2, 'Ostrava'), (3, 'Plzeň'), (4, 'Liberec'), (5, 'Olomouc'),
	  (6, 'České Budějovice'), (7, 'Ústí nad Label'), (8, 'Karlovy Vary'), (9, 'Zlín'),
	  (10, 'Jihlava'), (11, 'Děčín'), (12, 'Beroun'), (13, 'Pardubice'), (14, 'Hradec Králové'),
	  (15, 'Šumperk'), (16, 'Bohumín'), (17, 'Znojmo'), (18, 'Prostějov'), (19, 'Přerov')

	print '';
	print 'Start generating ' + cast(@rec_count as varchar) + ' records into table Customer ...'

select @cnt_fname_male = count(*) from @gtt_fname_male
select @cnt_fname_female = count(*) from @gtt_fname_female
select @cnt_lname_male = count(*) from @gtt_lname_male
select @cnt_lname_female = count(*) from @gtt_lname_female
select @cnt_residence = count(*) from @gtt_residence

                                          print '#fname_male: ' + cast(@cnt_fname_male as varchar)
	print '#fname_female: ' + cast(@cnt_fname_female as varchar)
	print '#lname_male: ' + cast(@cnt_lname_male as varchar)
	print '#lname_female: ' + cast(@cnt_lname_female as varchar)
	print '#residence: ' + cast(@cnt_residence as varchar)

select @crn_date = SYSDATETIME()

-- Main loop generating the @rec_count Customers
DECLARE @i int = 0
	WHILE @i < @rec_count
BEGIN

		DECLARE @age_in_months int = rand() * @max_age_over_min + @min_age_month + 1

		IF cast(rand() * 2 as int) = 0
			-- insert male Customer
			INSERT INTO Customer(idCustomer, fname, lname, residence, gender, birthday) VALUES (@i,
				(SELECT name FROM @gtt_fname_male WHERE id = cast(rand() * @cnt_fname_male as int)),
				(SELECT name FROM @gtt_lname_male WHERE id = cast(rand() * @cnt_lname_male as int)),
				(SELECT name FROM @gtt_residence WHERE id = cast(rand() * @cnt_residence as int)),
				'm',
				DATEADD(day, cast(rand() * 31 as int), DATEADD(month, -@age_in_months, @crn_date)));
ELSE
			-- insert female Customer
			INSERT INTO Customer(idCustomer, fname, lname, residence, gender, birthday) VALUES (@i,
				(SELECT name FROM @gtt_fname_female WHERE id = cast(rand() * @cnt_fname_female as int)),
				(SELECT name FROM @gtt_lname_female WHERE id = cast(rand() * @cnt_lname_female as int)),
				(SELECT name FROM @gtt_residence WHERE id = cast(rand() * @cnt_residence as int)),
				'f',
				DATEADD(day, cast(rand() * 31 as int), DATEADD(month, -@age_in_months, @crn_date)));

		SET @i = @i + 1
END

COMMIT
    print 'Customer data generated and commited'

SELECT @rec_count = count(*) FROM Customer
                                      print 'Table Customer includes ' + cast(@rec_count as varchar) + ' records.';

END TRY
BEGIN CATCH
SELECT
    ERROR_NUMBER() AS ErrorNumber
     ,ERROR_MESSAGE() AS ErrorMessage;
ROLLBACK

    print 'Rollback'
END CATCH
END

GO

-------------------------------------------------------

CREATE OR ALTER PROCEDURE generate_products AS
BEGIN
SET NOCOUNT ON

BEGIN TRANSACTION
BEGIN TRY

	DECLARE @rec_count int = 100000
	DECLARE @product_name_min int = 1
	DECLARE @product_name_max int = 50

	DECLARE @cnt_producer int
	DECLARE @cnt_product int

	DECLARE @gtt_producer TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_product TABLE(id INT, name VARCHAR(40), min_price INT, max_price INT)

	INSERT INTO @gtt_producer VALUES
	  (0, 'Shimano'),  (1, 'Specialized'), (2, 'Superior'), (3, 'Sram'), (4, 'Samsung'), (5, 'Apple'),
	  (6, 'Dell'),  (7, 'LG'),  (8, 'Bosch'), (9, 'Siemens'), (10, 'AEG'), (11, 'Mora'),
	  (12, 'Eta'), (13, 'Volkswagen'), (14, 'Škoda'), (15, 'Tatra'),  (16, 'Peugot'),  (17, 'Opel'), (18, 'Fiat'),
	  (19, 'Lockheed Martin'), (20, 'Excalibur'), (21, 'Česká zbrojovka'), (22, 'Rheinmetall'), (23, 'Saab'),
	  (24, 'Boeing'),	(25, 'Airbus'),	(26, 'Narex'), (27, 'Hilti'), (28, 'John Deere'), (29, 'Zetor')

	INSERT INTO @gtt_product VALUES
	  (0, 'Auto', 600000, 2000000), (1, 'Tank', 20000000, 25000000), (2, 'Telefon', 500, 40000),
	  (3, 'Tablet', 500, 40000), (4, 'Notebook', 5000, 70000), (5, 'Desktop', 5000, 70000),
	  (6, 'Server', 150000, 1000000), (7, 'Diskové pole', 150000, 1000000), (8, 'HDD', 300, 35000),
	  (9, 'SDD', 300, 35000), (10, 'Puška', 10000, 100000), (11, 'Pistol', 10000, 100000),
	  (12, 'Stíhací letoun', 1200000000, 2000000000), (13, 'Bombardér', 1200000000, 2000000000),
	  (14, 'Horské kolo', 10000, 200000), (15, 'Silniční kolo', 10000, 200000), (16, 'Odpružená vidlice', 3000, 30000),
	  (17, 'Přehazovačka, MTB', 1000, 10000), (18, 'Pračka', 5000, 50000), (19, 'Lednička', 5000, 50000),
	  (20, 'Myčka', 5000, 50000), (21, 'Sušička', 5000, 50000), (22, 'Varná konvice', 1000, 5000),
	  (23, 'Mikrovlná trouba', 3000, 10000), (24, 'Mixér', 1000, 10000), (25, 'Vrtací kladivo', 7000, 70000),
	  (26, 'Bourací kladivo', 7000, 70000), (27, 'Svářečka', 7000, 70000), (28, 'Tepelné čerpadlo', 10000, 500000),
	  (29, 'Traktor', 1000000, 5000000), (30, 'Sněžná rolba', 1000000, 5000000)

  	print '';
	print 'Start generating ' + cast(@rec_count as varchar) + ' records into table Product ...';

SELECT @cnt_product = count(*) FROM @gtt_product
SELECT @cnt_producer = count(*) FROM @gtt_producer

                                         print '#producer: ' + cast(@cnt_producer as varchar);
print '#product: ' + cast(@cnt_product as varchar);

	-- Perform @rec_count inserts into Product table
	-- The values of attributes will be the following:
		-- idProduct will be from 0 to @rec_count
		-- name will be a concatenation of random name from @gtt_product and number between @product_name_min and @product_name_max
		-- unit_price will be between @gtt_product.min_price and @gtt_product.max_price
		-- producer will be a random value taken from @gtt_producer
		-- decription will be null

	-- Delete: begin
	DECLARE @i int = 0
	WHILE @i < @rec_count
BEGIN
		DECLARE @product_id int = cast(rand() * @cnt_product as int)
		INSERT INTO Product(idProduct, name, unit_price, producer, description) VALUES (@i,
			(SELECT name + ' ' + cast(floor(rand() * (@product_name_max - @product_name_min) + @product_name_min) as varchar) FROM @gtt_product WHERE id = @product_id),
			(SELECT (rand() * (gttp.max_price - gttp.min_price) + gttp.min_price) FROM @gtt_product gttp WHERE id = @product_id),
			(SELECT name FROM @gtt_producer WHERE id = cast(rand() * @cnt_producer as int)),
			null)

		SET @i = @i + 1
END
	-- Delete: end

COMMIT
    print 'Product data generated and commited'
SELECT @rec_count = count(*) FROM Product
                                      print 'Table Product includes ' + cast(@rec_count as varchar) + ' records.';

RETURN
END TRY
BEGIN CATCH
SELECT
    ERROR_NUMBER() AS ErrorNumber
     ,ERROR_MESSAGE() AS ErrorMessage;
ROLLBACK

    print 'Product data insert - Rollback'
END CATCH
END

GO

-------------------------------------------------------


CREATE OR ALTER PROCEDURE generate_stores AS
BEGIN
SET NOCOUNT ON
BEGIN TRANSACTION
BEGIN TRY

	DECLARE @gtt_store_name TABLE(id INT, name VARCHAR(40))
	DECLARE @gtt_residence TABLE(id INT, name VARCHAR(40))

	DECLARE @rec_count int = 1000
	DECLARE @store_name_min int = 1;
	DECLARE @store_name_max int = 50;

	DECLARE @cnt_store_name int
	DECLARE @cnt_residence int

	INSERT INTO @gtt_store_name VALUES
	  (0, 'Hornbach'), (1, 'Alza'), (2, 'Mall'), (3, 'T.S.BOHEMIA'), (4, 'Datart'), (5, 'Globus'),
	  (6, 'Tesco'), (7, 'Euronics'), (8, 'Okay'), (9, 'Comfor'), (10, 'CZC')

	INSERT INTO @gtt_residence VALUES
	  (0, 'Jihlava'), (1, 'Praha'), (2, 'Brno'), (3, 'Ostrava'), (4, 'Plzeň'), (5, 'Liberec'),  (6, 'Olomouc'),
	  (7, 'České Budějovice'), (8, 'Ústí nad Label'), (9, 'Karlovy Vary'), (10, 'Zlín'), (11, 'Děčín'),
	  (12, 'Beroun'),	(13, 'Pardubice'), (14, 'Hradec Králové'), (15, 'Šumperk'), (16, 'Bohumín'),
	  (17, 'Znojmo'), (18, 'Prostějov'), (19, 'Přerov')

	print '';
	print 'Start generating ' + cast(@rec_count as varchar) + ' records into table Store ...'

SELECT @cnt_store_name = count(*) FROM @gtt_store_name
SELECT @cnt_residence = count(*) FROM @gtt_residence

                                          print '#store_name: ' + cast(@cnt_store_name as varchar)
	print '#residence: ' + cast(@cnt_residence as varchar)

-- Main loop
DECLARE @i int = 0
	WHILE @i < @rec_count
BEGIN

INSERT INTO Store VALUES (@i,
                          (SELECT name + ' ' + cast(floor(rand() * (@store_name_max - @store_name_min) + @store_name_min) as varchar) FROM @gtt_store_name WHERE id = cast(rand() * @cnt_store_name as int)),
                          (SELECT name FROM @gtt_residence WHERE id = cast(rand() * @cnt_residence as int)))

    SET @i = @i + 1
END

COMMIT
    print 'Store data generated and commited'

SELECT @rec_count = count(*) FROM Store
                                      print 'Table Store includes ' + cast(@rec_count as varchar) + ' records.';

END TRY
BEGIN CATCH
SELECT
    ERROR_NUMBER() AS ErrorNumber
     ,ERROR_MESSAGE() AS ErrorMessage;
ROLLBACK

    print 'Rollback'
END CATCH
END
GO

-------------------------------------------------------

create or alter procedure generate_staff as
begin
set nocount on
begin transaction
begin try
	declare @gtt_fname_male TABLE(id INT, name VARCHAR(40))
	declare @gtt_fname_female TABLE(id INT, name VARCHAR(40))
	declare @gtt_lname_male TABLE(id INT, name VARCHAR(40))
	declare @gtt_lname_female TABLE(id INT, name VARCHAR(40))
	declare @gtt_residence TABLE(id INT, name VARCHAR(40))
	declare @gtt_start_contract TABLE(id INT, start_contract date)

	declare @rec_count int = 10000
	declare @min_age_month int = 216; -- 18y
	declare @max_age_over_min int = 960; -- 80y => max age is 98y
	declare @max_staff_num int = 9999;

	declare @cnt_fname_male int
	declare @cnt_fname_female int
	declare @cnt_lname_male int
	declare @cnt_lname_female int
	declare @cnt_residence int
	declare @crn_date date
	declare @cnt_start_contract int
	declare @cnt_store int

	-- Prepare the table variables
	INSERT INTO @gtt_fname_male
	VALUES (0, 'Jiří'),	(1, 'Jan'),	(2, 'Petr'), (3, 'Josef'), (4, 'Pavel'), (5, 'Martin'),
	  (6, 'Tomáš'), (7, 'Jaroslav'), (8, 'Miroslav'),	(9, 'Zdeněk'), (10, 'Václav'),
	  (11, 'Michal'), (12, 'František'), (13, 'Jakub'), (14, 'Milan')

	insert into @gtt_fname_female
	values (0, 'Jana'), (1, 'Marie'), (2, 'Eva'), (3, 'Hana'), (4, 'Anna'), (5, 'Lenka'),
	  (6, 'Kateřina'), (7, 'Lucie'), (8, 'Věra'), (9, 'Alena')

	insert into @gtt_lname_male
	values (0, 'Novák'), (1, 'Svoboda'), (2, 'Novotný'), (3, 'Dvořák'), (4, 'Černý'), (5, 'Procházka'),
	  (6, 'Kučera'), (7, 'Veselý'), (8, 'Krejčí'), (9, 'Horák'), (10, 'Němec'), (11, 'Marek')

	insert into @gtt_lname_female
	values (0, 'Nováková'), (1, 'Svobodová'), (2, 'Novotná'), (3, 'Dvořáková'), (4, 'Černá'),
	  (5, 'Procházková'), (6, 'Kučerová'), (7, 'Veselá'), (8, 'Horáková'), (9, 'Němcová'),
	  (10, 'Marková'), (11, 'Pokorná'), (12, 'Pospíšilová')

	insert into @gtt_residence
	values (0, 'Praha'), (1, 'Brno'), (2, 'Ostrava'), (3, 'Plzeň'), (4, 'Liberec'), (5, 'Olomouc'),
	  (6, 'České Budějovice'), (7, 'Ústí nad Label'), (8, 'Karlovy Vary'), (9, 'Zlín'),
	  (10, 'Jihlava'), (11, 'Děčín'), (12, 'Beroun'), (13, 'Pardubice'), (14, 'Hradec Králové'),
	  (15, 'Šumperk'), (16, 'Bohumín'), (17, 'Znojmo'), (18, 'Prostějov'), (19, 'Přerov')

	insert into @gtt_start_contract
	values (0, '2016-01-01'), (1, '2017-01-01'), (2, '2018-01-01'), (3, '2019-01-01'),
	  (4, '2020-01-01'), (5, '2021-01-01'), (6, '2022-01-01'),
	  (7, '2023-01-01'), (8, '2024-01-01'), (9, '2025-01-01')

	print '';
	print 'Start generating ' + cast(@rec_count as varchar) + ' records into table Staff ...'

select @cnt_fname_male = count(*) from @gtt_fname_male
select @cnt_fname_female = count(*) from @gtt_fname_female
select @cnt_lname_male = count(*) from @gtt_lname_male
select @cnt_lname_female = count(*) from @gtt_lname_female
select @cnt_residence = count(*) from @gtt_residence
select @cnt_start_contract = count(*) from @gtt_start_contract
select @cnt_store=count(*) from Store;

print '#fname_male: ' + cast(@cnt_fname_male as varchar)
	print '#fname_female: ' + cast(@cnt_fname_female as varchar)
	print '#lname_male: ' + cast(@cnt_lname_male as varchar)
	print '#lname_female: ' + cast(@cnt_lname_female as varchar)
	print '#residence: ' + cast(@cnt_residence as varchar)
	print '#start_contract: ' + cast(@cnt_start_contract as varchar)

select @crn_date = SYSDATETIME()

-- Main loop generating the @rec_count Customers
DECLARE @i int = 0
	WHILE @i < @rec_count
BEGIN
      declare @male_female int = cast(rand() * 2 as int);
      declare @fname varchar(20);
      declare @lname varchar(20);

	  if @male_female = 0
begin
	    set @fname = (SELECT name FROM @gtt_fname_male WHERE id = cast(rand() * @cnt_fname_male as int));
	    set @lname = (SELECT name FROM @gtt_lname_male WHERE id = cast(rand() * @cnt_lname_male as int));
end
else
begin
	    set @fname = (SELECT name FROM @gtt_fname_female WHERE id = cast(rand() * @cnt_fname_female as int));
	    set @lname = (SELECT name FROM @gtt_lname_female WHERE id = cast(rand() * @cnt_lname_female as int));
end

      -- generate id of the staff like nem135 for Němec
	  declare @idStaff varchar(7)
      declare @v_cntIds int = 0;
      declare @j int = 0;
	  while @j <= @max_staff_num
begin
        set @idStaff = lower(substring(@fname,1,1) + translate(substring(@lname,1,2), 'Ččě', 'cce')) + cast(@j as varchar)
select @v_cntIds=count(*) from Staff where idStaff = @idStaff
    if @v_cntIds = 0
		  break
set @j = @j + 1
end

	  DECLARE @age_in_months int = rand() * @max_age_over_min + @min_age_month + 1

	  IF @male_female = 0
		-- insert male Customer
		INSERT INTO Staff(idStaff, fname, lname, residence, gender, birthday,
		  start_contract, end_contract, idStore)
		VALUES (@idStaff,	@fname, @lname,
		  (SELECT name FROM @gtt_residence WHERE id = cast(rand() * @cnt_residence as int)),
		  'm',
		  DATEADD(day, cast(rand() * 31 as int), DATEADD(month, -@age_in_months, @crn_date)),
		  (SELECT start_contract FROM @gtt_start_contract WHERE id = cast(rand() * @cnt_start_contract as int)),
		  null,
		  cast(rand() * @cnt_store as int));
ELSE
		-- insert female Customer
		INSERT INTO Staff(idStaff, fname, lname, residence, gender, birthday,
		  start_contract, end_contract, idStore)
		VALUES (@idStaff, @fname, @lname,
		  (SELECT name FROM @gtt_residence WHERE id = cast(rand() * @cnt_residence as int)),
		  'f',
		  DATEADD(day, cast(rand() * 31 as int), DATEADD(month, -@age_in_months, @crn_date)),
		  (SELECT start_contract FROM @gtt_start_contract WHERE id = cast(rand() * @cnt_start_contract as int)),
		  null,
		  cast(rand() * @cnt_store as int));

		SET @i = @i + 1
END

COMMIT
    print 'Customer data generated and commited'

SELECT @rec_count = count(*) FROM Staff
                                      print 'Table Staff includes ' + cast(@rec_count as varchar) + ' records.';

END TRY
BEGIN CATCH
SELECT
    ERROR_NUMBER() AS ErrorNumber
     ,ERROR_MESSAGE() AS ErrorMessage;
ROLLBACK

    print 'Rollback'
END CATCH
END

GO

-------------------------------------------------------

CREATE OR ALTER PROCEDURE generate_orders AS
BEGIN
SET NOCOUNT ON
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @rec_count int = 5000000
	DECLARE @min_age_month int = 216  -- 18y
	DECLARE @item_count_max int = 20
	DECLARE @quantity_max int = 10

	-- the count of records from the table
	DECLARE @customer_count int
	DECLARE @store_count int
	DECLARE @product_count int

	DECLARE @item_count int
	DECLARE @time_month_count int
	DECLARE @orderItem_unique int

	DECLARE @crn_date date

	print '';
	print 'Start generating ' + cast(@rec_count as varchar) + ' records into table OrderItem ...'

SELECT @customer_count = count(*) from Customer
SELECT @store_count = count(*) from Store
SELECT @product_count = count(*) from Product

select @crn_date = SYSDATETIME()

-- Main loop
DECLARE @i int = 0
	DECLARE @total_order_items int = 0
	WHILE @total_order_items < @rec_count
BEGIN
		SET @i = @i + 1

		DECLARE @id_cust INT = cast(rand() * @customer_count as int)
		DECLARE @customer_order_date_min DATE = DATEADD(month, @min_age_month, (SELECT birthday FROM Customer WHERE idCustomer = @id_cust))
		declare @idStore int = cast(rand() * @store_count as int)

        -- select a random staff of the store
		declare @v_staff_cnt int
select @v_staff_cnt = count(*) from Staff where idStore=@idStore;

declare @v_staff_rnd int = cast(rand() * @v_staff_cnt as int);
		declare @idStaff varchar(7)

select @idStaff=idStaff from
    (
        select
            rank() over (
	          order by idStaff desc
            ) ro,
                idStaff
        from Staff
        where idStore=@idStore
    ) t
where ro = @v_staff_rnd;

INSERT INTO "Order" VALUES (
                               @i,
                               DATEADD(month, cast(rand() * DATEDIFF(month, @customer_order_date_min, @crn_date) as int), @customer_order_date_min),
                               @id_cust, null, @idStore, @idStaff)

DECLARE @cnt_order_items int = cast(rand() * @item_count_max + 0.48 as int)
		DECLARE @k int = 0
		WHILE @k < @cnt_order_items and @total_order_items < @rec_count
BEGIN
			-- select product
			DECLARE @selected_productid int = rand() * @product_count
			IF (not exists(SELECT 1 FROM OrderItem WHERE idOrder = @i and idProduct = @selected_productid))
BEGIN
				-- when the product is not in the order
				SET @k = @k + 1
				SET @total_order_items = @total_order_items + 1

				IF (rand() * 2 > 1)
					INSERT INTO OrderItem VALUES (
						@i,
						@selected_productid,
						(SELECT unit_price + cast(rand() * unit_price / 10 as bigint)  FROM Product WHERE idProduct = @selected_productid),
						cast(rand() * (@quantity_max - 1) as int) + 1
					)
				ELSE
					INSERT INTO OrderItem VALUES (
						@i,
						@selected_productid,
						(SELECT unit_price - cast(rand() * unit_price / 10 as bigint)  FROM Product WHERE idProduct = @selected_productid),
						cast(rand() * (@quantity_max - 1) as int) + 1
					)
END
END
END
COMMIT

    print 'Orders and OrderItem data generated and commited'

SELECT @rec_count = count(*) FROM "Order"
                                      print 'Table Orders includes ' + cast(@rec_count as varchar) + ' records.';

SELECT @rec_count = count(*) FROM OrderItem
                                      print 'Table OrderItem includes ' + cast(@rec_count as varchar) + ' records.';

END TRY
BEGIN CATCH
SELECT
    ERROR_NUMBER() AS ErrorNumber
     ,ERROR_MESSAGE() AS ErrorMessage;
ROLLBACK

    print 'Rollback'
END CATCH
END
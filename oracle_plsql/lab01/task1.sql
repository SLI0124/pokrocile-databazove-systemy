-- 1.2.1. - počet záznamů v tabulkách na začátku
SELECT COUNT(*) as customer_count
FROM customer;
SELECT COUNT(*) as order_count
FROM "Order";
SELECT COUNT(*) as order_item_count
FROM OrderItem;
SELECT COUNT(*) as product_count
FROM Product;
SELECT COUNT(*) as staff_count
FROM staff;
SELECT COUNT(*) as store_count
FROM store;

-- 1.2.2. - počet stránek v tabulkách na začátku
call PrintPages('CUSTOMER', 'SLI0124');
call PRINTPAGES('Order', 'SLI0124');
call PRINTPAGES('ORDERITEM', 'SLI0124');
call PRINTPAGES('PRODUCT', 'SLI0124');
call PrintPages('STAFF', 'SLI0124');
call PrintPages('STORE', 'SLI0124');

-- 1.3.1. - mazání záznamů z tabulky OrderItem a Order
DELETE
FROM OrderItem;

DELETE
FROM "Order";

-- velikost tabulky Order a OrderItem po delete
call PrintPages('Order', 'SLI0124');
call PrintPages('ORDERITEM', 'SLI0124');

-- 1.3.2. - fyzické mazání stránek z tabulky Order a OrderItem
alter table "Order"
    enable row movement;

alter table "Order"
    shrink space;

alter table OrderItem
    enable row movement;

alter table OrderItem
    shrink space;

call PrintPages('Order', 'SLI0124');
call PrintPages('ORDERITEM', 'SLI0124');

-- 1.3.3. - vytvoření nových záznamů zpět
call GENERATE_ORDERS();

-- 1.3.4.- velikost tabulky Order a OrderItem po 2. vytvoření
call PRINTPAGES('Order', 'SLI0124');
call PRINTPAGES('ORDERITEM', 'SLI0124');

-- 1.3.5. - Customer před a po shrink
call PrintPages('CUSTOMER', 'SLI0124');

alter table Customer
    enable row movement;

alter table Customer
    shrink space;

call PrintPages('CUSTOMER', 'SLI0124');
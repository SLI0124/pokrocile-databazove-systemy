-- 1.2.1 - počet záznamů v tabulkách na začátku
SELECT COUNT(*) as customer_count
FROM customer AS customer_count;
SELECT COUNT(*) as order_count
FROM "Order" AS order_count;
SELECT COUNT(*) as order_item_count
FROM OrderItem AS order_item_count;
SELECT COUNT(*) as product_count
FROM Product AS product_count;
SELECT COUNT(*) as staff_count
FROM staff AS staff_count;
SELECT COUNT(*) as store_count
FROM store;

-- 1.2.2. - počet stránek v tabulkách na začátku
EXEC PrintPagesHeap 'Customer';
EXEC PrintPagesHeap 'Order';
EXEC PrintPagesHeap 'OrderItem';
EXEC PrintPagesHeap 'Product';
EXEC PrintPagesHeap 'Staff';
EXEC PrintPagesHeap 'Store';

-- 1.3.1.- mazání záznamů z tabulky OrderItem a Order
DELETE
FROM OrderItem;

DELETE
FROM "Order";

-- velikost tabulky Order a OrderItem po delete
EXEC PrintPagesHeap "Order";
EXEC PrintPagesHeap "OrderItem";

-- 1.3.2.- fyzické mazání stránek
alter table "Order"
    rebuild;

alter table OrderItem
    rebuild;

PrintPagesHeap "Order";
PrintPagesHeap "OrderItem";

-- 1.3.3. - vytvoření nových záznamů zpět
EXEC generate_orders

-- 1.3.4. - velikost tabulky Order a OrderItem po 2. vytvoření
EXEC PrintPagesHeap "Order";
EXEC PrintPagesHeap "OrderItem";

-- 1.3.5. - Customer před a po rebuild
EXEC PrintPagesHeap "Customer";
alter table Customer
    rebuild;
EXEC PrintPagesHeap "Customer";
-- ProductOrderDb, A database for Physical Database Design
-- SQL Server Version
--
-- Michal Kratky, Radim Baca
-- dbedu@cs.vsb.cz, 2023-2024
-- last update: 2025-02-14

drop table IF EXISTS OrderItem
drop table IF EXISTS "Order"
drop table IF EXISTS Staff
drop table IF EXISTS Store
drop table IF EXISTS Product
drop table IF EXISTS Customer

create table Customer (
                          idCustomer int primary key nonclustered,
                          fName varchar(20) not null,
                          lName varchar(30) not null,
                          residence varchar(20) not null,
                          gender char(1) not null,
                          birthday date not null
);

create table Product (
                         idProduct int primary key nonclustered,
                         name varchar(30) not null,
                         unit_price int not null,
                         producer varchar(30) not null,
                         description varchar(2000) null
);

create table Store (
                       idStore int primary key nonclustered,
                       name varchar(30) not null,
                       residence varchar(20) not null
);

create table Staff (
                       idStaff varchar(7) primary key nonclustered,
                       fName varchar(20) not null,
                       lName varchar(30) not null,
                       residence varchar(20) not null,
                       gender char(1) not null,
                       birthday date not null,
                       start_contract date not null,
                       end_contract date default null,
                       idStore int references Store(idStore) not null
);

create table "Order" (
                         idOrder int primary key nonclustered,
                         order_datetime date not null,
                         idCustomer int references Customer(idCustomer) not null,
                         order_status varchar(10),
                         idStore int references Store(idStore) not null,
                         idStaff varchar(7) references Staff(idStaff) not null
);

create table OrderItem (
                           idOrder int references "Order"(idOrder) not null,
                           idProduct int references Product(idProduct) not null,
                           unit_price bigint not null,
                           quantity int not null,
                           primary key nonclustered(idOrder, idProduct)
); 
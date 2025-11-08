-- Minimal Northwind-like sample (tiny) for quick start
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS shippers CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE customers(
  customer_id   varchar PRIMARY KEY,
  company_name  text NOT NULL,
  country       text
);

CREATE TABLE shippers(
  shipper_id    integer PRIMARY KEY,
  company_name  text NOT NULL
);

CREATE TABLE employees(
  employee_id   integer PRIMARY KEY,
  first_name    text,
  last_name     text
);

CREATE TABLE orders(
  order_id      integer PRIMARY KEY,
  customer_id   varchar REFERENCES customers(customer_id),
  employee_id   integer REFERENCES employees(employee_id),
  order_date    date,
  required_date date,
  shipped_date  date,
  ship_via      integer REFERENCES shippers(shipper_id)
);

CREATE TABLE order_details(
  order_id    integer REFERENCES orders(order_id),
  product_id  integer,
  unit_price  numeric(10,2),
  quantity    integer,
  discount    numeric(4,3) DEFAULT 0,
  PRIMARY KEY(order_id, product_id)
);

INSERT INTO customers(customer_id, company_name, country) VALUES
('ALFKI','Alfreds Futterkiste','Germany'),
('BLAUS','Blauer See Delikatessen','Germany'),
('BONAP','Bon app''','France');

INSERT INTO shippers(shipper_id, company_name) VALUES
(1,'Speedy Express'),(2,'United Package'),(3,'Federal Shipping');

INSERT INTO employees(employee_id, first_name, last_name) VALUES
(1,'Nancy','Davolio'),(2,'Andrew','Fuller'),(3,'Janet','Leverling');

-- Three orders: one on-time, one late, one no-SLA
INSERT INTO orders(order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via) VALUES
(10248,'ALFKI',1,'1996-07-04','1996-07-10','1996-07-09',1), -- ON_TIME
(10249,'BLAUS',2,'1996-07-05','1996-07-10','1996-07-13',2), -- LATE (3d)
(10250,'BONAP',3,'1996-07-08',NULL,'1996-07-12',3);         -- NO_SLA

INSERT INTO order_details(order_id, product_id, unit_price, quantity, discount) VALUES
(10248,11,14.00,12,0.0),
(10249,42, 9.80,10,0.1),
(10250,51,53.00,20,0.0);

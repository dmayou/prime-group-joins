CREATE TABLE customers (

    id SERIAL PRIMARY KEY,

    first_name VARCHAR(60),

    last_name VARCHAR(80)

);



CREATE TABLE addresses (

    id SERIAL PRIMARY KEY,

    street VARCHAR(255),

    city VARCHAR(60),

    state VARCHAR(2),

    zip VARCHAR(12),

    address_type VARCHAR(8),

    customer_id integer REFERENCES customers

);



CREATE TABLE orders (

    id SERIAL PRIMARY KEY,

    order_date date,

    address_id integer REFERENCES addresses

);



CREATE TABLE products (

    id SERIAL PRIMARY KEY,

    description VARCHAR(255),

    unit_price numeric(3,2)

);



CREATE TABLE line_items (

    id SERIAL PRIMARY KEY,

    quantity integer,

    order_id integer REFERENCES orders,

    product_id integer REFERENCES products

);



CREATE TABLE warehouse (

    id SERIAL PRIMARY KEY,

    warehouse VARCHAR(55),

    fulfillment_days integer

);



CREATE TABLE warehouse_product (

    product_id integer NOT NULL REFERENCES products,

    warehouse_id integer NOT NULL REFERENCES warehouse,

    on_hand integer,

    PRIMARY KEY (product_id, warehouse_id)

);



INSERT INTO customers 

VALUES (1, 'Lisa', 'Bonet'),

(2, 'Charles', 'Darwin'),

(3, 'George', 'Foreman'),

(4, 'Lucy', 'Liu');



INSERT INTO addresses 

VALUES (1, '1 Main St', 'Detroit', 'MI', '31111', 'home', 1), 

(2, '555 Some Pl', 'Chicago', 'IL', '60611', 'business', 1),

(3, '8900 Linova Ave', 'Minneapolis', 'MN', '55444', 'home', 2),

(4, 'PO Box 999', 'Minneapolis', 'MN', '55334', 'business', 3),

(5, '3 Charles Dr', 'Los Angeles', 'CA', '00000', 'home', 4),

(6, '934 Superstar Ave', 'Portland', 'OR', '99999', 'business', 4);



INSERT INTO orders 

VALUES (1, '2010-03-05', 1),

(2, '2012-02-08', 2),

(3, '2016-02-07', 2),

(4, '2011-03-04', 3),

(5, '2012-09-22', 5),

(6, '2012-09-23', 6),

(7, '2012-09-23', 2),

(8, '2012-09-23', 1),

(9, '2013-05-25', 5);



INSERT INTO products 

VALUES (1, 'toothbrush', 3.00),

(2, 'nail polish - blue', 4.25),

(3, 'can of beans', 2.50),

(4, 'lysol', 6.00),

(5, 'cheetos', 0.99),

(6, 'diet pepsi', 1.20),

(7, 'wet ones baby wipes', 8.99);



INSERT INTO line_items 

VALUES (1, 16, 1, 1),

(2, 4, 1, 2),

(3, 2, 1, 3),

(4, 3, 2, 4),

(5, 1, 2, 5),

(6, 6, 3, 6),

(7, 4, 4, 7),

(8, 7, 4, 1),

(9, 2, 4, 2),

(10, 4, 4, 3),

(11, 10, 4, 4),

(12, 3, 4, 5),

(13, 5, 5, 6),

(14, 4, 5, 7),

(15, 9, 5, 1),

(16, 3, 5, 2),

(17, 6, 5, 3),

(18, 3, 6, 4),

(19, 7, 6, 5),

(20, 1, 6, 6),

(21, 2, 6, 7),

(22, 4, 6, 1),

(23, 7, 6, 2),

(24, 8, 7, 3),

(25, 6, 7, 4),

(26, 9, 7, 5);



INSERT INTO warehouse VALUES (1, 'alpha', 2),

(2, 'beta', 3),

(3, 'delta', 4),

(4, 'gamma', 4),

(5, 'epsilon', 5);



INSERT INTO warehouse_product 

VALUES (1, 3, 0),

(1, 1, 5),

(2, 4, 20),

(3, 5, 3),

(4, 2, 9),

(4, 3, 12),

(5, 3, 7),

(6, 1, 1),

(7, 2, 4),

(6, 3, 88),

(6, 4, 3);

-- BASE MODE
-- 	1.	Get all customers and their addresses.
SELECT c.first_name, c.last_name,
		a.street, a.city, a.state, a.zip FROM customers AS c
JOIN addresses AS a ON c.id = a.customer_id;

--	2.	Get all orders and their line items (orders, quantity and product).
SELECT orders.id, orders.order_date,
		line_items.quantity, products.description FROM orders
JOIN line_items ON orders.id = line_items.order_id
JOIN products ON line_items.product_id = products.id;

--	3.	Which warehouses have cheetos?
SELECT warehouse.warehouse FROM warehouse
JOIN warehouse_product ON warehouse_product.warehouse_id = warehouse.id
JOIN products ON warehouse_product.product_id = products.id
WHERE products.description = 'cheetos';

--	4.	Which warehouses have diet pepsi?
SELECT warehouse.warehouse FROM warehouse
JOIN warehouse_product ON warehouse_product.warehouse_id = warehouse.id
JOIN products ON warehouse_product.product_id = products.id
WHERE products.description = 'diet pepsi';

--	5.	Get the number of orders for each customer. NOTE: It is OK if those without orders are not included in results.
SELECT COUNT(*), customers.first_name, customers.last_name FROM orders
JOIN addresses ON orders.address_id = addresses.id
JOIN customers ON addresses.customer_id = customers.id
GROUP BY customers.id;

--	6.	How many customers do we have?
SELECT COUNT(*) FROM customers;
--	7.	How many products do we carry?
SELECT COUNT(*) FROM products;
--	8.	What is the total available on-hand quantity of diet pepsi?
SELECT SUM(warehouse_product.on_hand) FROM products
JOIN warehouse_product ON products.id = warehouse_product.product_id
WHERE products.description = 'diet pepsi';

-- STRETCH MODE
--	9.	How much was the total cost for each order?
SELECT orders.id as order_id, CONCAT(customers.last_name, ', ', customers.first_name) AS full_name, SUM(line_items.quantity * products.unit_price) FROM orders
JOIN line_items ON orders.id = line_items.order_id
JOIN products ON products.id = line_items.product_id
JOIN addresses ON orders.address_id = addresses.id
JOIN customers ON addresses.customer_id = customers.id
GROUP BY orders.id, full_name
ORDER BY orders.id;

--	10.	How much has each customer spent in total?
SELECT CONCAT(customers.last_name, ', ', customers.first_name) AS full_name, 
		customers.id,
		SUM(products.unit_price * line_items.quantity) 
		FROM products
JOIN line_items ON line_items.product_id = products.id
JOIN orders ON line_items.order_id = orders.id
JOIN addresses ON orders.address_id = addresses.id
JOIN customers ON customers.id = addresses.customer_id
GROUP BY customers.id;

--	11.	How much has each customer spent in total? Customers who have spent $0 should still show up in the table. It should say 0, not NULL (research coalesce).
SELECT CONCAT(customers.last_name, ', ', customers.first_name) AS full_name, 
		customers.id,
		COALESCE (SUM(products.unit_price * line_items.quantity), 0) AS sum
		FROM products
JOIN line_items ON line_items.product_id = products.id
JOIN orders ON line_items.order_id = orders.id
RIGHT JOIN addresses ON orders.address_id = addresses.id
JOIN customers ON customers.id = addresses.customer_id
GROUP BY customers.id;

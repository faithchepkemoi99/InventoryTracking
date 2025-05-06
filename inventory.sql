-- Creating the database for inventory tracking
CREATE DATABASE Inv_tracking;

-- creating the first table in the database
-- Stores the category information for products
CREATE TABLE categories (
categoryID INT AUTO_INCREMENT PRIMARY KEY,
category_name VARCHAR(100) NOT NULL
);

-- creating table suppliers
-- Stores supplier details for sourcing products
CREATE TABLE suppliers(
supplierID INT AUTO_INCREMENT PRIMARY KEY,
supplier_name VARCHAR(100) NOT NULL,
contact_email VARCHAR(100) UNIQUE
);

-- Creating products table
-- Stores product information and stock quantities
CREATE TABLE products (
productID INT AUTO_INCREMENT PRIMARY KEY,
product_name VARCHAR(100) NOT NULL,
categoryID INT NOT NULL,
supplierID INT NOT NULL,
price DECIMAL(10, 2) NOT NULL,
stock_quantity INT DEFAULT 0,
FOREIGN KEY (categoryID) REFERENCES categories(categoryID),
FOREIGN KEY (supplierID) REFERENCES suppliers(supplierID)
);

--creating inventory/stock rotation table
-- Table: inventory_rotation
-- This table logs the movement of inventory in and out of the system.
-- 'change_amount' records the quantity changed (positive for IN, negative for OUT).
-- 'rotation_type' is an ENUM type that only accepts either 'IN' or 'OUT' to ensure valid entry types.
CREATE TABLE stock_rotation(
rotationID INT AUTO_INCREMENT PRIMARY KEY,
productID INT NOT NULL,
change_amount INT NOT NULL,
rotation_type ENUM('IN', 'OUT') NOT NULL,-- 'Specifies if the change is incoming or outgoing', -- Type of stock movement
rotation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (productID) REFERENCES products(productID)
);

-- SAMPLE DATA
-- inserting into categories table
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Stationery'),
('Furniture');

-- inserting into suppliers
INSERT INTO suppliers (supplier_name, contact_email) VALUES
('Tech Haven', 'support@techhave.com'),
('Office Essentials', 'sales@officessentials.com'),
('Home Decor', 'infor@homedecor.com');

--inserting into products
INSERT INTO products (productID, product_name, categoryID, supplierID, price, stock_quantity) VALUES
(101, 'Laptop', 1, 1,  799.12, 20),
(103, 'Desk Chair', 3, 3, 114.50, 40),
(102, 'notebook', 2, 2, 15.99, 150);  

--inserting into inventory movements
INSERT INTO stock_rotation (productID, change_amount, rotation_type) VALUES
(101, 10, 'IN'),
(102, -59, 'OUT'),
(103, -14, 'IN'); 
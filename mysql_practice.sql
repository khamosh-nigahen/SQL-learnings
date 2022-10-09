-- Used this link for practice and understanding concepts - https://www.mysqltutorial.org/getting-started-with-mysql/

-- Few things to understand when working with RDBMS
-- ER models - https://www.geeksforgeeks.org/introduction-of-er-model/?ref=lbp
-- Database Normalization - https://www.geeksforgeeks.org/introduction-of-database-normalization/?ref=lbp
-- ACID properties - https://www.geeksforgeeks.org/acid-properties-in-dbms/?ref=lbp
-- SQL ransactions - https://www.geeksforgeeks.org/sql-transactions/


show databases;
use classicmodels;

-- Questions and things to learn
-- rollup clause
-- go through this for using a stored procedure before renaming a table - https://www.mysqltutorial.org/mysql-rename-table/
-- self referencing foreign key


-- order by clause
-- ORDER BY
--     column1 ASC,
--     column2 DESC;
--     
-- In this case, the ORDER BY clause:

-- First, sort the result set by the values in the column1 in ascending order.
-- Then, sort the sorted result set by the values in the column2  in descending order. Note that the order of values in the column1 will not change in this step, only the order of values in the column2 changes.

select * from customers;
select customerName, customerNumber from customers order by customerName desc, customerNumber;

-- something like this will be the result if you get lastname desc and firstname asc

-- +-----------------+------------------+
-- | contactLastname | contactFirstname |
-- +-----------------+------------------+
-- | Young           | Dorothy          |
-- | Young           | Jeff             |
-- | Young           | Julie            |
-- | Young           | Mary             |
-- | Yoshido         | Juri             |
-- | Walker          | Brydey           |
-- | Victorino       | Wendy            |
-- | Urs             | Braun            |

-- ==================================================================

select * from orderdetails;

-- here u can use the column alias for order by 
SELECT 
    orderNumber,
    orderLineNumber,
    quantityOrdered * priceEach AS subtotal
FROM
    orderdetails
ORDER BY subtotal DESC;

-- Since MySQL evaluates the SELECT clause before the ORDER BY clause, you can use the column alias specified in the SELECT clause in the ORDER BY clause.

-- FIELD() funtion

-- The FIELD() function returns the position of the str in the str1, str2, … list. If the str is not in the list, the FIELD() function returns 0. 
-- Here The 'In process', 'on Hold' sequence matters because filed function checks from start if it gets it returns the id of it

SELECT 
    orderNumber, status
FROM
    orders
ORDER BY FIELD(status,
        'In Process',
        'On Hold',
        'Cancelled',
        'Resolved',
        'Disputed',
        'Shipped');
        
-- In MySQL, NULL comes before non-NULL values. Therefore, when you the ORDER BY clause with the ASC option, NULLs appear first in the result set.

-- DISTINCT Clause

SELECT 
    DISTINCT lastname
FROM
    employees
ORDER BY 
    lastname;

-- When you specify multiple columns in the DISTINCT clause, the DISTINCT clause will use the combination of values in these columns to determine the uniqueness of the row in the result set.
SELECT 
    distinct state, city
FROM
    customers
WHERE
    state IS NOT NULL
ORDER BY 
    state , 
    city;

-- IN operator

SELECT 
    officeCode, 
    city, 
    phone, 
    country
FROM
    offices
WHERE
    country IN ('USA' , 'France');
    
-- BETWEEN operator

-- value BETWEEN low AND high;
-- value >= low AND value <= high

-- value NOT BETWEEN low AND high
-- value < low OR value > high

SELECT 
    productCode, 
    productName, 
    buyPrice
FROM
    products
WHERE
    buyPrice BETWEEN 90 AND 100;
    
-- LIKE operator

-- expression LIKE pattern ESCAPE escape_character

-- In this syntax, if the expression matches the pattern, the LIKE operator returns 1. Otherwise, it returns 0.

-- MySQL provides two wildcard characters for constructing patterns: percentage % and underscore _ .

-- The percentage ( % ) wildcard matches any string of zero or more characters.
-- The underscore ( _ ) wildcard matches any single character.
-- For example, s% matches any string starts with the character s such as sun and six. The se_ matches any string starts with  se and is followed by any character such as see and sea.

-- When the pattern contains the wildcard character and you want to treat it as a regular character, you can use the ESCAPE clause.

-- Aliases 

SELECT
	CONCAT_WS(', ', lastName, firstname) as `Full name`
FROM
	employees
ORDER BY
	`Full name`;
    
-- remember, that you cannot use a column alias in the WHERE clause. The reason is that when MySQL evaluates the WHERE clause, the values of columns specified in the SELECT clause are not be evaluated yet.

-- table name alias (important when working with joins)

SELECT 
    e.firstName, 
    e.lastName
FROM
    employees e
ORDER BY e.firstName;

-- GROUP BY

-- group by clause syntax

-- SELECT 
--     c1, c2,..., cn, aggregate_function(ci)
-- FROM
--     table
-- WHERE
--     where_conditions
-- GROUP BY c1 , c2,...,cn;

SELECT 
    status, customerNumber
FROM
    orders
GROUP BY status;

-- with aggregate function

SELECT 
    status, COUNT(*)
FROM
    orders
GROUP BY status;

-- Remember in this sequence the query works
-- from -> where -> group by -> select -> distinct -> order by -> limit

select orderNumber `order no.`, -- alias but as is not mentinoed explicitly
	SUM(priceEach * quantityOrdered) as total
from
	orderDetails
group by 
	`order no.`
having
	total > 6000;

-- If you use the GROUP BY clause in the SELECT statement without using aggregate functions, the GROUP BY clause behaves like the DISTINCT clause.

-- The following statement uses the GROUP BY clause to select the unique states of customers from the customers table.

SELECT 
    state
FROM
    customers
GROUP BY state;
-- the above one is simlar to the below one
SELECT DISTINCT
    state
FROM
    customers;

-- Generally speaking, the DISTINCT clause is a special case of the GROUP BY clause. The difference between DISTINCT clause and GROUP BY clause is that the GROUP BY clause sorts the result set, whereas the DISTINCT clause does not.

-- HAVING clause

-- The HAVING clause is often used with the GROUP BY clause to filter groups based on a specified condition. If you omit the GROUP BY clause, the HAVING clause behaves like the WHERE clause.

-- Remember in this sequence the query works
-- from -> where -> group by -> having -> select -> distinct -> order by -> limit

SELECT 
    ordernumber,
    SUM(quantityOrdered) AS itemsCount,
    SUM(priceeach*quantityOrdered) AS total
FROM
    orderdetails
GROUP BY 
   ordernumber
HAVING 
   total > 1000;
   
select * from orderDetails where orderNumber = 10100;

SELECT 
    ordernumber,
    SUM(quantityOrdered) AS itemsCount,
    SUM(priceeach*quantityOrdered) AS total
FROM
    orderdetails
GROUP BY ordernumber
HAVING 
    total > 1000 AND 
    itemsCount > 600;

-- The HAVING clause is only useful when you use it with the GROUP BY clause to generate the output of the high-level reports. For example, you can use the HAVING clause to answer the questions like finding the number of orders this month, this quarter, or this year that have a total amount greater than 10K.

-- SUBQUERY

SELECT 
    lastName, firstName
FROM
    employees
WHERE
    officeCode IN (SELECT 
            officeCode
        FROM
            offices
        WHERE
            country = 'USA');

-- When executing the query, MySQL evaluates the subquery first and uses the result of the subquery for the outer query.

SELECT 
    customerNumber, 
    checkNumber, 
    amount
FROM
    payments
WHERE
    amount > (SELECT 
            AVG(amount)
        FROM
            payments);

-- If a subquery returns more than one value, you can use other operators such as IN or NOT IN operator in the WHERE clause.

-- like here we can get customers who has not placed any orders
SELECT 
    customerName
FROM
    customers
WHERE
    customerNumber NOT IN (SELECT DISTINCT
            customerNumber
        FROM
            orders);
            
-- When you use a subquery in the FROM clause, the result set returned from a subquery is used as a temporary table. This table is referred to as a derived table or materialized subquery.

SELECT 
    MAX(items), 
    MIN(items), 
    FLOOR(AVG(items))
FROM (select orderNumber, count(orderNumber) as items from orderDetails group by orderNumber) as lineitems;

-- Unlike a standalone subquery, a correlated subquery is a subquery that uses the data from the outer query. In other words, a correlated subquery depends on the outer query. A correlated subquery is evaluated once for each row in the outer query.

-- The following example uses a correlated subquery to select products whose buy prices are greater than the average buy price of all products in each product line.

SELECT 
    productname, 
    buyprice
FROM
    products p1
WHERE
    buyprice > (SELECT 
            AVG(buyprice)
        FROM
            products
        WHERE
            productline = p1.productline);
            
-- In this example, both outer query and correlated subquery reference the same products table. Therefore, we need to use a table alias p1 for the products table in the outer query.

-- Derived table

-- Every derived table must have its own alias.

-- SELECT 
--     select_list
-- FROM
--     (SELECT 
--         select_list
--     FROM
--         table_1) derived_table_name
-- WHERE 
--     derived_table_name.c1 > 0;

select * from orders;
select * from customers;

select customerName, phone from (select customerName, phone from customers) derived_table where derived_table.customerName = 'Blauer See Auto, Co.';

-- Update

UPDATE employees 
SET 
    email = 'mary.patterson@classicmodelcars.com'
WHERE
    employeeNumber = 1056;
    
UPDATE employees 
SET 
    lastname = 'Hill',
    email = 'mary.hill@classicmodelcars.com'
WHERE
    employeeNumber = 1056;

UPDATE employees
SET email = REPLACE(email,'@classicmodelcars.com','@mysqltutorial.org')
WHERE
   jobTitle = 'Sales Rep' AND
   officeCode = 6;
   
-- DELETE (Always do delete or update in a transaction block)

-- For a table that has a foreign key constraint, when you delete rows from the parent table, the rows in the child table will be deleted automatically by using the ON DELETE CASCADE option.

DELETE FROM customers
ORDER BY customerName
LIMIT 4;

-- CREATE TABLE syntax

-- CREATE TABLE [IF NOT EXISTS] table_name(
--    column_1_definition,
--    column_2_definition,
--    ...,
--    table_constraints
-- ) ENGINE=storage_engine;

-- column name syntax
-- column_name data_type(length) [NOT NULL] [DEFAULT value] [AUTO_INCREMENT] column_constraint;

--  if you want to set a column or a group of columns as the primary key, you use the following syntax:
-- PRIMARY KEY (col1,col2,...)

CREATE TABLE IF NOT EXISTS checklists (
    todo_id INT AUTO_INCREMENT,
    task_id INT,
    todo VARCHAR(255) NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (todo_id , task_id),
    FOREIGN KEY (task_id)
        REFERENCES tasks (task_id)
        ON UPDATE RESTRICT ON DELETE CASCADE
);

-- Add more columns to an existing table

ALTER TABLE vehicles
ADD color VARCHAR(50),
ADD note VARCHAR(255);

-- Alter exisitng columns in the table

ALTER TABLE vehicles 
MODIFY year SMALLINT NOT NULL,
MODIFY color VARCHAR(20) NULL AFTER make;

-- rename a column

ALTER TABLE vehicles 
CHANGE COLUMN note vehicleCondition VARCHAR(100) NOT NULL;

-- drop a colum

ALTER TABLE vehicles
DROP COLUMN vehicleCondition;

-- rename a table

ALTER TABLE vehicles 
RENAME TO cars; 


-- PRIMARY KEY

-- A primary key is a column or a set of columns that uniquely identifies each row in the table.  The primary key follows these rules:

-- A primary key must contain unique values. If the primary key consists of multiple columns, the combination of values in these columns must be unique.
-- A primary key column cannot have NULL values. Any attempt to insert or update NULL to primary key columns will result in an error. Note that MySQL implicitly adds a NOT NULL constraint to primary key columns.
-- A table can have one an only one primary key.

-- When you define a primary key for a table, MySQL automatically creates an index called PRIMARY.

CREATE TABLE users(
   user_id INT AUTO_INCREMENT PRIMARY KEY,
   username VARCHAR(40),
   password VARCHAR(255),
   email VARCHAR(255)
);

CREATE TABLE roles(
   role_id INT AUTO_INCREMENT,
   role_name VARCHAR(50),
   PRIMARY KEY(role_id)
);

CREATE TABLE user_roles(
   user_id INT,
   role_id INT,
   PRIMARY KEY(user_id,role_id),
   FOREIGN KEY(user_id) 
       REFERENCES users(user_id),
   FOREIGN KEY(role_id) 
       REFERENCES roles(role_id)
);

-- KEY is the synonym for INDEX. You use the KEY when you want to create an index for a column or a set of columns that is not the part of a primary key or unique key.

-- A UNIQUE index ensures that values in a column must be unique. Unlike the PRIMARY index, MySQL allows NULL values in the UNIQUE index. In addition, a table can have multiple UNIQUE indexes.

-- ALTER TABLE users
-- ADD UNIQUE INDEX username_unique (username ASC) ;

-- ALTER TABLE users
-- ADD UNIQUE INDEX  email_unique (email ASC) ;


-- FOREIGN KEY

-- A foreign key is a column or group of columns in a table that links to a column or group of columns in another table. The foreign key places constraints on data in the related tables, which allows MySQL to maintain referential integrity.

-- The relationship between customers table and orders table is one-to-many. And this relationship is established by the foreign key in the orders table specified by the customerNumber column.

-- The customerNumber column in the orders table links to the customerNumber primary key column in the customers table.

-- The customers table is called the parent table or referenced table, and the orders table is known as the child table or referencing table.

-- Typically, the foreign key columns of the child table often refer to the primary key columns of the parent table.

-- A table can have more than one foreign key where each foreign key references to a primary key of the different parent tables.


CREATE DATABASE fkdemo;

USE fkdemo;

CREATE TABLE categories(
    categoryId INT AUTO_INCREMENT PRIMARY KEY,
    categoryName VARCHAR(100) NOT NULL
) ENGINE=INNODB;

CREATE TABLE newproducts(
    productId INT AUTO_INCREMENT PRIMARY KEY,
    productName varchar(100) not null,
    categoryId INT,
    CONSTRAINT fk_category
    FOREIGN KEY (categoryId) 
        REFERENCES categories(categoryId)
) ENGINE=INNODB;

--  not prviding a constarint name, mysql gives a random name to it
CREATE TABLE testtable(
    testId INT AUTO_INCREMENT PRIMARY KEY,
    testName varchar(100) not null,
    productId INT,
    CONSTRAINT 
    FOREIGN KEY (productId) 
        REFERENCES newproducts(productId)
) ENGINE=INNODB;

-- trying to check if the RESTRICT option shows
show create table newproducts;

-- RESTRICT option in the constraint

INSERT INTO categories(categoryName)
VALUES
    ('Smartphone'),
    ('Smartwatch');
    
INSERT INTO newproducts(productName, categoryId)
VALUES('iPhone',1);

-- below query fails as categoryId 3 is not present on the parent table
INSERT INTO newproducts(productName, categoryId)
VALUES('iPad',3);

-- below query also fails because catergorgyId 1 is there in newproducts table 
UPDATE categories
SET categoryId = 100
WHERE categoryId = 1;


-- ONE UPDATE CASCADE and ON DELETE CASCADE

drop table newproducts;

CREATE TABLE products(
    productId INT AUTO_INCREMENT PRIMARY KEY,
    productName varchar(100) not null,
    categoryId INT NOT NULL,
    CONSTRAINT fk_category
    FOREIGN KEY (categoryId) 
    REFERENCES categories(categoryId)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=INNODB;

INSERT INTO products(productName, categoryId)
VALUES
    ('iPhone', 1), 
    ('Galaxy Note',1),
    ('Apple Watch',2),
    ('Samsung Galary Watch',2);
    
-- Hence when you update any row in categoriess table the products table also get updated on categoryId due to ON UPDATE CASCADE
UPDATE categories
SET categoryId = 100
WHERE categoryId = 1;

-- Here ON DELETE CASCADE also deletes the rows in products table which has categoryId 2
DELETE FROM categories
WHERE categoryId = 2;

select * from categories;

-- ON UPDATE SET NULL and ON DELETE SET NULL the rows will exist but the categoryId column will be having the value NULL

-- DROP the foreign key constraints

ALTER TABLE products 
DROP FOREIGN KEY fk_category;

-- You can disable an enable foreign key check, sometimes it is required when you are importing data from a csv file or something like that
SET foreign_key_checks = 0;
SET foreign_key_checks = 1;

-- UNIQUE COnstraint

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    PRIMARY KEY (supplier_id),
    CONSTRAINT uc_name_address UNIQUE (name , address)
);

show create table suppliers;
-- When you define a unique constraint, MySQL creates a corresponding UNIQUE index and uses this index to enforce the rule.

SHOW INDEX FROM suppliers;

--  drop a unique constraint
DROP INDEX uc_name_address ON suppliers;

--  add a unique constraint
ALTER TABLE suppliers
ADD CONSTRAINT uc_name_address 
UNIQUE (name,address);


-- CHECK constraint

CREATE TABLE parts (
    part_no VARCHAR(18) PRIMARY KEY,
    description VARCHAR(40),
    cost DECIMAL(10,2 ) NOT NULL CHECK (cost >= 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

SHOW CREATE TABLE parts; 

-- the below query fails because it violates the check constraint for price which should not the negative
INSERT INTO parts(part_no, description,cost,price) 
VALUES('A-001','Cooler',0,-100);

-- let create one more check where price should be greater than cost
DROP TABLE IF EXISTS parts;

-- here we have given the name of the check constraint
CREATE TABLE parts (
    part_no VARCHAR(18) PRIMARY KEY,
    description VARCHAR(40),
    cost DECIMAL(10,2 ) NOT NULL CHECK (cost >= 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    CONSTRAINT parts_chk_price_gt_cost 
        CHECK(price >= cost)
);

-- fails because the check constraint parts_chk_price_gt_cost is violated
INSERT INTO parts(part_no, description,cost,price) 
VALUES('A-001','Cooler',200,100);

-- DEFAULT constraint

CREATE TABLE cart_items 
(
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DEC(5,2) NOT NULL,
    sales_tax DEC(5,2) NOT NULL DEFAULT 0.1,
    CHECK(quantity > 0),
    CHECK(sales_tax >= 0) 
);

desc cart_items;

INSERT INTO cart_items(name, quantity, price, sales_tax)
VALUES('Battery',4, 0.25 , DEFAULT);

select * from cart_items;

-- alter default value
ALTER TABLE cart_items
ALTER COLUMN quantity SET DEFAULT 1; 

-- removing default column
ALTER TABLE cart_items
ALTER COLUMN quantity DROP DEFAULT;

-- Stored procedures

-- DELIMITER $$

-- By definition, a stored procedure is a segment of declarative SQL statements stored inside the MySQL Server. In this example, we have just created a stored procedure with the name GetCustomers().


-- CREATE PROCEDURE GetCustomers()
-- BEGIN
-- 	SELECT 
-- 		customerName, 
-- 		city, 
-- 		state, 
-- 		postalCode, 
-- 		country
-- 	FROM
-- 		customers
-- 	ORDER BY customerName;    
-- END$$
-- DELIMITER ;


-- CALL GetCustomers();

-- The first time you invoke a stored procedure, MySQL looks up for the name in the database catalog, compiles the stored procedure’s code, place it in a memory area known as a cache, and execute the stored procedure.

-- If you invoke the same stored procedure in the same session again, MySQL just executes the stored procedure from the cache without having to recompile it.

-- A stored procedure can have parameters so you can pass values to it and get the result back. For example, you can have a stored procedure that returns customers by country and city. In this case, the country and city are parameters of the stored procedure.

-- A stored procedure may contain control flow statements such as IF, CASE, and LOOP that allow you to implement the code in the procedural way.

-- A stored procedure can call other stored procedures or stored functions, which allows you to modulize your code.

-- Stored procedures have their own advantages and disadvantages so before using it ead this - https://www.mysqltutorial.org/introduction-to-sql-stored-procedures.aspx



-- TRIGGERS

-- In MySQL, a trigger is a stored program invoked automatically in response to an event such as insert, update, or delete that occurs in the associated table. For example, you can define a trigger that is invoked automatically before a new row is inserted into a table.

-- The SQL standard defines two types of triggers: row-level triggers and statement-level triggers.

-- A row-level trigger is activated for each row that is inserted, updated, or deleted.  For example, if a table has 100 rows inserted, updated, or deleted, the trigger is automatically invoked 100 times for the 100 rows affected.
-- A statement-level trigger is executed once for each transaction regardless of how many rows are inserted, updated, or deleted.

-- Advantages of triggers
-- Triggers provide another way to check the integrity of data.
-- Triggers handle errors from the database layer.
-- Triggers give an alternative way to run scheduled tasks. By using triggers, you don’t have to wait for the scheduled events to run because the triggers are invoked automatically before or after a change is made to the data in a table.
-- Triggers can be useful for auditing the data changes in tables.
-- Disadvantages of triggers
-- Triggers can only provide extended validations, not all validations. For simple validations, you can use the NOT NULL, UNIQUE, CHECK and FOREIGN KEY constraints.
-- Triggers can be difficult to troubleshoot because they execute automatically in the database, which may not invisible to the client applications.
-- Triggers may increase the overhead of the MySQL Server.

use classicmodels;

CREATE TABLE employees_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employeeNumber INT NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    changedat DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL
);

-- triggger syntax

-- CREATE TRIGGER trigger_name
-- {BEFORE | AFTER} {INSERT | UPDATE| DELETE }
-- ON table_name FOR EACH ROW
-- trigger_body;

CREATE TRIGGER before_employee_update 
    BEFORE UPDATE ON employees
    FOR EACH ROW 
 INSERT INTO employees_audit
 SET action = 'update',
     employeeNumber = OLD.employeeNumber,
     lastname = OLD.lastname,
     changedat = NOW();
     
-- To distinguish between the value of the columns BEFORE and AFTER the DML has fired, you use the NEW and OLD modifiers.
-- For example, if you update the column description, in the trigger body, you can access the value of the description before the update OLD.description and the new value NEW.description.

-- show all triggers in the current database by using the SHOW TRIGGERS statement:
show triggers;

-- if we update this e,ployee data the trigger will come in action and update the emoployee_audit table
UPDATE employees 
SET 
    lastName = 'Dushe'
WHERE
    employeeNumber = 1056;
    
select * from employees_audit;

-- drop trigger

DROP TRIGGER before_billing_update;

-- Database views

-- A better way tto save the query in the database server and assign a name to it. This named query is called a database view, or simply, view.

CREATE VIEW customerPayments
AS 
SELECT 
    customerName, 
    checkNumber, 
    paymentDate, 
    amount
FROM
    customers
INNER JOIN
    payments USING (customerNumber);

SELECT * FROM customerPayments;

-- Note that a view does not physically store the data. When you issue the SELECT statement against the view, MySQL executes the underlying query specified in the view’s definition and returns the result set. For this reason, sometimes, a view is referred to as a virtual table.

-- why we use views:- https://www.mysqltutorial.org/mysql-views-tutorial.aspx

SHOW FULL TABLES; -- for views

-- Algorithms used by Views [MERGE, TEMPTABLE, UNDEFINED] - moreinfo - https://www.mysqltutorial.org/mysql-views/mysql-view-processing-algorithms/

-- INDEXES

-- An index is a data structure such as B-Tree that improves the speed of data retrieval on a table at the cost of additional writes and storage to maintain it.

-- A brief about B-tree -  https://www.geeksforgeeks.org/introduction-of-b-tree-2/?ref=lbp

-- CREATE INDEX idx_c4 ON table_name(column_4);

explain SELECT 
    employeeNumber, 
    lastName, 
    firstName
FROM
    employees
WHERE
    jobTitle = 'Sales Rep';

CREATE INDEX jobTitle ON employees(jobTitle);

-- show all the indexes in the table
SHOW INDEXES FROM employees;

-- drop indexes
DROP INDEX name ON leads;

-- The lock_option controls the level of concurrent reads and writes on the table while the index is being removed.
DROP INDEX email ON leads
ALGORITHM = INPLACE 
LOCK = DEFAULT;

-- to get the invisible indexes of the table
SHOW INDEXES FROM employees
WHERE visible = 'NO';

-- index based on column which is string and taking the string prefix for indexing
CREATE INDEX idx_productname 
ON products(productName(20));

-- composite index
CREATE INDEX index_name 
ON table_name(c2,c3,c4);
-- Notice that if you have a composite index on (c1,c2,c3), you will have indexed search capabilities on one the following column combinations:
-- (c1)
-- (c1,c2)
-- (c1,c2,c3)

-- invisible index
-- The invisible indexes allow you to mark indexes as unavailable for the query optimizer. MySQL maintains the invisible indexes and keeps them up to date when the data in the columns associated with the indexes changes.
-- As mentioned earlier, the query optimizer does not use invisible index so why do you use the invisible index in the first place? Practically speaking, invisible indexes have a number of applications. For example, you can make an index invisible to see if it has an impact to the performance and mark the index visible again if it does.
CREATE INDEX extension 
ON employees(extension) INVISIBLE;

-- descending index
-- A descending index is an index that stores key values in the descending order. it is useful when u want to query from that last entries
CREATE TABLE t(
    a INT NOT NULL,
    b INT NOT NULL,
    INDEX a_asc_b_desc (a ASC, b DESC)
);

-- Clustered index

-- A clustered index, on the other hand, is the table. It is an index that enforces the ordering on the rows of the table physically.

-- Once a clustered index is created, all rows in the table will be stored according to the key columns used to create the clustered index.

-- Because a clustered index store the rows in sorted order, each table have only one clustered index.

-- Each InnoDB table requires a clustered index. The clustered index helps an InnoDB table optimize data manipulations such as SELECT, INSERT, UPDATE and DELETE.

-- When defining a primary key for an InnoDB table, MySQL uses the primary key as the clustered index.

-- If you do not have a primary key for a table, MySQL will search for the first UNIQUE index where all the key columns are NOT NULL and use this UNIQUE index as the clustered index.

-- In case the InnoDB table has no primary key or suitable UNIQUE index, MySQL internally generates a hidden clustered index named GEN_CLUST_INDEX on a synthetic column that contains the row ID values.

-- As a result, each InnoDB table always has one and only one clustered index.

-- All indexes other than the clustered index are the non-clustered indexes or secondary indexes. In InnoDB tables, each record in the secondary index contains the primary key columns for the row as well as the columns specified in the non-clustered index. MySQL uses this primary key value for the row lookups in the clustered index.

-- Therefore, it is advantageous to have a short primary key otherwise the secondary indexes will use more space. Typically, the auto-increment integer column is used for the primary key column.

-- REGEX with query
SELECT 
    productname
FROM
    products
WHERE
    productname REGEXP 'ford';
    

-- AGGREGATE FUNCTIONS

select * from orderDetails where orderNUmber = 10100;

-- SUM()
select orderNumber, sum(priceEach) from orderDetails group by orderNumber;    

SELECT 
    productCode, 
    SUM(priceEach * quantityOrdered) total
FROM
    orderDetails
GROUP BY productCode
ORDER BY total DESC;

-- AVG()

SELECT 
    productLine, 
    AVG(buyPrice)
FROM
    products
GROUP BY productLine
ORDER BY productLine;

-- AVG with distinct
SELECT 
    FORMAT(AVG(DISTINCT buyprice), 2)
FROM
    products;
    
    
-- COUNT()
-- group by used because of sql_mode=only_full_group_by
SELECT 
    productLine, 
    COUNT(*)
FROM
    products
GROUP BY productLine
ORDER BY productLine;

-- The COUNT(*) function is often used with a GROUP BY clause to return the number of elements in each group.

-- MAX()

SELECT 
    productLine, MAX(buyPrice)
FROM
    products
GROUP BY productLine
ORDER BY MAX(buyPrice) DESC;

-- MIN()

SELECT 
    productLine, 
    MIN(buyPrice)
FROM
    products
GROUP BY productLine
ORDER BY MIN(buyPrice);

-- ÇOMPARIOSN FUNCTIONS
-- COALESCE Function -  substitutes N/A instead of NULL if the column is empty
SELECT 
    customerName, city, COALESCE(state, 'N/A'), country
FROM
    customers;

-- Window Functions
-- READ this - https://www.mysqltutorial.org/mysql-window-functions/

-- table lock 

-- A lock is a flag associated with a table. MySQL allows a client session to explicitly acquire a table lock for preventing other sessions from accessing the same table during a specific period.
-- A client session can acquire or release table locks only for itself. And a client session cannot acquire or release table locks for other client sessions.
-- more on table locks:- https://www.mysqltutorial.org/mysql-table-locking/

-- JOINS
-- some basic joins example where foreign key is not used

use fkdemo;
-- creating basic tables
CREATE TABLE members (
    member_id INT AUTO_INCREMENT,
    name VARCHAR(100),
    PRIMARY KEY (member_id)
);

CREATE TABLE committees (
    committee_id INT AUTO_INCREMENT,
    name VARCHAR(100),
    PRIMARY KEY (committee_id)
);

INSERT INTO members(name)
VALUES('John'),('Jane'),('Mary'),('David'),('Amelia');

INSERT INTO committees(name)
VALUES('John'),('Mary'),('Amelia'),('Joe');

-- inner join - as here not foreign key is involved as tables do not define the foreign key
-- The inner join clause compares each row from the first table with every row from the second table.
-- If values from both rows satisfy the join condition, the inner join clause creates a new row whose column contains all columns of the two rows from both tables and includes this new row in the result set. In other words, the inner join clause includes only matching rows from both tables.
select * from members inner join committees on members.name = committees.name;

-- If the join condition uses the equality operator (=) and the column names in both tables used for matching are the same, and you can use the USING clause instead:
select * from members inner join committees using(name);
select * from committees inner join members using(name);

-- left join

-- The left join selects data starting from the left table. For each row in the left table, the left join compares with every row in the right table.

-- If the values in the two rows satisfy the join condition, the left join clause creates a new row whose columns contain all columns of the rows in both tables and includes this row in the result set.

-- If the values in the two rows are not matched, the left join clause still creates a new row whose columns contain columns of the row in the left table and NULL for columns of the row in the right table.

-- In other words, the left join selects all data from the left table whether there are matching rows exist in the right table or not.

-- In case there are no matching rows from the right table found, the left join uses NULLs for columns of the row from the right table in the result set.

select m.member_id, m.name as member, c.committee_id, c.name as committee from members m left join committees c on m.name = c.name;

select m.member_id, m.name as member, c.committee_id, c.name as committee from committees c left join members m on m.name = c.name;

select m.member_id, m.name as member, c.committee_id, c.name as committee from committees c left join members m using(name);

-- To find members who are not the committee members

SELECT 
    m.member_id, 
    m.name AS member, 
    c.committee_id, 
    c.name AS committee
FROM
    members m
LEFT JOIN committees c USING(name)
WHERE c.committee_id IS NULL;

-- Generally, this query pattern can find rows in the left table that do not have corresponding rows in the right table.

-- Right join

-- The right join clause is similar to the left join clause except that the treatment of left and right tables is reversed. The right join starts selecting data from the right table instead of the left table.
-- The right join clause selects all rows from the right table and matches rows in the left table. If a row from the right table does not have matching rows from the left table, the column of the left table will have NULL in the final result set.

SELECT 
    m.member_id, 
    m.name AS member, 
    c.committee_id, 
    c.name AS committee
FROM
    members m
RIGHT JOIN committees c on c.name = m.name;

-- cross join

-- Unlike the inner join, left join, and right join, the cross join clause does not have a join condition.
-- The cross join makes a Cartesian product of rows from the joined tables. The cross join combines each row from the first table with every row from the right table to make the result set.
-- Suppose the first table has n rows and the second table has m rows. The cross join that joins the tables will return nxm rows.

SELECT 
    m.member_id, 
    m.name AS member, 
    c.committee_id, 
    c.name AS committee
FROM
    members m
CROSS JOIN committees c;

-- The cross join is useful for generating planning data. For example, you can carry the sales planning by using the cross join of customers, products, and years


-- Some advance join queries using the foreign key
use classicmodels;

SELECT 
    productCode, 
    productName, 
    textDescription
FROM
    products t1
INNER JOIN productlines t2 
    ON t1.productline = t2.productline;
    
SELECT 
    t1.orderNumber,
    status,
    SUM(quantityOrdered * priceEach) total
FROM
    orders t1
INNER JOIN orderdetails t2 
    ON t1.orderNumber = t2.orderNumber
GROUP BY orderNumber;

-- 3 table inner joins
select orderNumber, orderLineNumber, productLine from orders inner join orderDetails using(orderNumber) inner join products using(productCode);

-- 4 table inner join
SELECT 
    orderNumber,
    orderDate,
    customerName,
    orderLineNumber,
    productName,
    quantityOrdered,
    priceEach
FROM
    orders
INNER JOIN orderdetails 
    USING (orderNumber)
INNER JOIN products 
    USING (productCode)
INNER JOIN customers 
    USING (customerNumber)
ORDER BY 
    orderNumber, 
    orderLineNumber;
    
-- other operators also u can use like > , < , <>
SELECT 
    orderNumber, 
    productName, 
    msrp, 
    priceEach,
    count(*) as total
FROM
    products p
INNER JOIN orderdetails o 
   ON p.productcode = o.productcode
      AND p.msrp > o.priceEach
WHERE
    p.productcode = 'S10_1678'
group by orderNumber;

-- left join examples

select customers.customerNumber, 
    customerName, 
    orderNumber, 
    status 
from customers left join orders using(customerNumber);

-- The LEFT JOIN clause is very useful when you want to find rows in a table that doesn’t have a matching row from another table.

-- here salesRepEmployeeNUmber is fk and is equal to employee number just the name is different in that table

SELECT 
    lastName, 
    firstName, 
    customerName, 
    checkNumber, 
    amount
FROM
    employees
LEFT JOIN customers ON 
    employeeNumber = salesRepEmployeeNumber
LEFT JOIN payments ON 
    payments.customerNumber = customers.customerNumber
ORDER BY 
    customerName, 
    checkNumber;
    
-- In this case, the query returns all orders but only the order 10123 will have line items associated with it
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails d 
    ON o.orderNumber = d.orderNumber AND 
       o.orderNumber = 10123;
       
-- for thee above query if you only the orders of 10123 use the where clause
SELECT 
    o.orderNumber, 
    customerNumber, 
    productCode
FROM
    orders o
LEFT JOIN orderDetails 
    USING (orderNumber)
WHERE
    orderNumber = 10123;

-- right join examples

SELECT 
    employeeNumber, 
    customerNumber
FROM
    customers
RIGHT JOIN employees 
    ON salesRepEmployeeNumber = employeeNumber
ORDER BY 
	employeeNumber;
    
-- below query shows the employees who are not in charge of any customer
SELECT 
    employeeNumber, 
    customerNumber
FROM
    customers
RIGHT JOIN employees ON 
	salesRepEmployeeNumber = employeeNumber
WHERE customerNumber is NULL
ORDER BY employeeNumber;

-- SELF JOIN

-- The self join is often used to query hierarchical data or to compare a row with other rows within the same table.
-- To perform a self join, you must use table aliases to not repeat the same table name twice in a single query. Note that referencing a table twice or more in a query without using table aliases will cause an error.

select * from employees;

-- The output only shows the employees who have a manager. However, you don’t see the President because his name is filtered out due to the INNER JOIN clause.
SELECT 
    CONCAT(m.lastName, ', ', m.firstName) AS Manager,
    CONCAT(e.lastName, ', ', e.firstName) AS 'Direct report'
FROM
    employees e
INNER JOIN employees m ON 
    m.employeeNumber = e.reportsTo
ORDER BY 
    Manager;

-- The President is the employee who does not have any manager or value in the reportsTo column is NULL .
-- Using left join to show the top manager also
SELECT 
    IFNULL(CONCAT(m.lastname, ', ', m.firstname),
            'Top Manager') AS 'Manager',
    CONCAT(e.lastname, ', ', e.firstname) AS 'Direct report'
FROM
    employees e
LEFT JOIN employees m ON 
    m.employeeNumber = e.reportsto
ORDER BY 
    manager DESC;

-- By using the MySQL self join, you can display a list of customers who locate in the same city by joining the customers table to itself.
select * from customers;

SELECT 
    c1.city, 
    c1.customerName, 
    c2.customerName
FROM
    customers c1
INNER JOIN customers c2 ON 
    c1.city = c2.city
    AND c1.customername > c2.customerName
ORDER BY 
    c1.city;
    
-- In this example, the table customers is joined to itself using the following join conditions:

-- c1.city = c2.city  makes sure that both customers have the same city.
-- c.customerName > c2.customerName ensures that no same customer is included.

-- CROSS JOIN in detial -> https://www.mysqltutorial.org/mysql-cross-join/



-- Some notes

-- MYSQL uses stoarge engines like InnoDB, MyISAM etc. InnoDB is the default storage engine
-- The contents of view will get updated automatically when the underlying table (forming the query) data gets changed. However, materialised views can be configured to refresh its contents periodically or can be manually refreshed when needed.
-- Merge is part of the DML commands in SQL which can be used either perform INSERT or UPDATE based on the data in the respective table. If the desired data is present then merge will update the records. If desired data is not present then merge will insert the records.
-- just a query for pe=revious date - SELECT DATE_SUB(SYSDATE(), INTERVAL 1 DAY) as previous_day; 
-- Function should always return a value whereas for a procedure it’s not mandatory to return a value. Function can be called from a SELECT query whereas procedure cannot be called from a SELECT query. Function is generally used to perform some calculation and return a result. Whereas procedure is generally used to implement some business logic.


-- Some SQL intervieew QUestions -  https://techtfq.com/blog/top-20-sql-interview-questions



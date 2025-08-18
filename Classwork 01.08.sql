docker run --name sqldb -v sqldb_volume:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234 -d mysql:8.4 / создали новый контейнер

docker start sqldb вход в этот контейнер
docker exec -it sqldb mysql -u root -p вход с паролем
SHOW DATABASES; - просмотр баз данных внутри контейнера
CREATE DATABASE cohort_65;
CREATE DATABASE  IF NOT EXISTS cohort_65; -  создание базы данных
SHOW WARNINGS;
DROP DATABASE  cohort_65;
DROP DATABASE  IF  EXISTS  cohort_65;
USE cohort_65; - войти в эту базу данных
SELECT DATABASE(); - запросить базу данных
SHOW TABLES; -  просмотр таблиц
SELECT * FROM products; - запрос всей таблицы products
CREATE TABLE IF NOT EXISTS products (
         productID    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
         productCode  CHAR(3)       NOT NULL DEFAULT '',
         name         VARCHAR(30)   NOT NULL DEFAULT '',
         quantity     INT UNSIGNED  NOT NULL DEFAULT 0,
         price        DECIMAL(7,2)  NOT NULL DEFAULT 99999.99,
         PRIMARY KEY  (productID) - ключ персональный к каждому товару
       ); создание таблицы


INSERT INTO products VALUES (1001, 'PEN', 'Pen Red', 5000, 1.23); - добаваление  одного товара  в таблицу
INSERT INTO products VALUES
         (NULL, 'PEN', 'Pen Blue',  8000, 1.25),
         (NULL, 'PEN', 'Pen Black', 2000, 1.25); - добавление несколько товаров
INSERT INTO products (productCode, name, quantity, price) VALUES
         ('PEC', 'Pencil 2B', 10000, 0.48),
         ('PEC', 'Pencil 2H', 8000, 0.49);
INSERT INTO products VALUES 
         (NULL, 'MRK', 'Marker Red', 2000, 2.49),
         (NULL, 'MRK', 'Marker Blue', 3000, 2.49);

CREATE TABLE suppliers (
         supplierID  INT UNSIGNED  NOT NULL AUTO_INCREMENT, 
         name        VARCHAR(30)   NOT NULL DEFAULT '', 
         phone       CHAR(8)       NOT NULL DEFAULT '',
         PRIMARY KEY (supplierID)
       ); -  создание второй таблицы поставщиков

INSERT INTO suppliers VALUE
          (501, 'ABC Traders', '88881111'), 
          (502, 'XYZ Company', '88882222'), 
          (503, 'QQ Corp', '88883333'); - вложение значений в таблицу поставщиков

SELECT * FROM suppliers; - запрос таблицы поставщиков
ALTER TABLE products
       ADD COLUMN supplierID INT UNSIGNED NOT NULL;
ALTER TABLE products
       ADD COLUMN supplierID INT UNSIGNED NOT NULL;

DESCRIBE products;
UPDATE products SET supplierID = 501;
ALTER TABLE products
       ADD FOREIGN KEY (supplierID) REFERENCES suppliers (supplierID);
UPDATE products SET supplierID = 502 WHERE productCode = 'PEC’ ;
 UPDATE products SET supplierID = 503 WHERE productCode = 'MRK' ;
SELECT * FROM products, suppliers;
SELECT * FROM products, suppliers WHERE products. supplierID = suppliers.supplierID ;
SELECT * FROM products  AS p, suppliers AS s WHERE p. supplierID = s.supplierID ;

SELECT * FROM products AS p, suppliers AS WHERE p. supplierID = s. supplierID;
SELECT * FROM products p, suppliers s WHERE p. supplierID = s. supplierID;

SELECT p.*, s. name, s. phone FROM products p, suppliers s
WHERE p. supplierID = s. supplierID AND price < 1.5;
UPDATE products SET supplierID = 520 WHERE productID = 1002; // не работает уже привязаны
INSERT INTO products (productCode, name, quantity, price, supplierID)
VALUES ('PEC', 'Caran d\'Ache', 1, 500, 502);

 JOIN по другому связывает таблицы. Более быстрее 
 
SELECT products.name, price, suppliers.name FROM products 
       JOIN suppliers ON products.supplierID = suppliers.supplierID
       WHERE price < 0.6;
       
--Many to Many----
ALTER TABLE products DROP FOREIGN KEY `products_ibfk_1`; 
ALTER TABLE products DROP COLUMN supplierID;       
CREATE TABLE products_suppliers (
         productID   INT UNSIGNED  NOT NULL,
         supplierID  INT UNSIGNED  NOT NULL,
                     -- Same data types as the parent tables
         PRIMARY KEY (productID, supplierID),
                     -- uniqueness
         FOREIGN KEY (productID)  REFERENCES products  (productID),
         FOREIGN KEY (supplierID) REFERENCES suppliers (supplierID)
       );       
INSERT INTO products_suppliers VALUES (1001, 501), (1002, 501),
       (1003, 501), (1004, 502), (1001, 503);
     
SELECT * FROM products_suppliers;     
INSERT INTO suppliers VALUES (511, 'MMM Inc', '12345678');

SELECT * FROM products_suppliers, products, suppliers;  

SELECT * FROM products_suppliers ps
         JOIN products p ON ps.productID= p.productID
         JOIN suppliers s ON ps.supplierID = s.supplierID;       

SELECT p.*, s.* FROM products_suppliers ps
         JOIN products p ON ps.productID= p.productID
         JOIN suppliers s ON ps.supplierID = s.supplierID; 
SELECT p.*, ps.supplierID FROM products p
         LEFT JOIN products_suppliers ps ON p.productID= ps.productID;

SELECT p.*, ps.supplierID FROM products p
         RIGHT JOIN products_suppliers ps ON p.productID= ps.productID;
         
SELECT ps.productID, s.* FROM products_suppliers ps
         RIGHT JOIN suppliers s ON ps.supplierID= s.supplierID;          
         
SELECT ps.productID, s.*  FROM suppliers s
         LEFT JOIN products_suppliers ps ON ps.supplierID= s.supplierID;  
 
  Домашняя работа
         
1. Показать всю информацию о товарах, поставляемых компанией «ABC Traders».
mysql> SELECT p.*
    -> FROM products p
    -> JOIN products_suppliers ps ON p.productID = ps.productID
    -> JOIN suppliers s ON ps.supplierID = s.supplierID
    -> WHERE s.name = 'ABC Traders';
+-----------+-------------+-----------+----------+-------+
| productID | productCode | name      | quantity | price |
+-----------+-------------+-----------+----------+-------+
|      1001 | PEN         | Pen Red   |     5000 |  1.23 |
|      1002 | PEN         | Pen Blue  |     8000 |  1.25 |
|      1003 | PEN         | Pen Black |     2000 |  1.25 |
+-----------+-------------+-----------+----------+-------+
3 rows in set (0.01 sec)
2. Показать общую стоимость всей продукции, поставляемой поставщиками: «XYZ Company», «QQ Corp».
mysql> SELECT s.name AS Supplier, SUM(p.price * p.quantity) AS TotalCost
    -> FROM products p
    -> JOIN products_suppliers ps ON p.productID = ps.productID
    -> JOIN suppliers s ON ps.supplierID = s.supplierID
    -> WHERE s.name IN ('XYZ Company', 'QQ Corp')
    -> GROUP BY s.name;
+-------------+-----------+
| Supplier    | TotalCost |
+-------------+-----------+
| XYZ Company |   4800.00 |
| QQ Corp     |   6150.00 |
+-------------+-----------+
2 rows in set (0.01 sec)

3. Показать среднюю цену поставки продукции по поставщикам.
mysql> SELECT s.name AS Supplier, AVG(p.price) AS AveragePrice
    -> FROM products p
    -> JOIN products_suppliers ps ON p.productID = ps.productID
    -> JOIN suppliers s ON ps.supplierID = s.supplierID
    -> GROUP BY s.name;
+-------------+--------------+
| Supplier    | AveragePrice |
+-------------+--------------+
| ABC Traders |     1.243333 |
| XYZ Company |     0.480000 |
| QQ Corp     |     1.230000 |
+-------------+--------------+
3 rows in set (0.00 sec)

4. Найдите поставщика самых дешевых маркеров (по коду MRK) и укажите его название, телефон и цену маркера.
mysql> SELECT s.name, s.phone, p.price
    -> FROM products p
    -> JOIN products_suppliers ps ON p.productID = ps.productID
    -> JOIN suppliers s ON ps.supplierID = s.supplierID
    -> WHERE p.productCode = 'MRK'
    -> ORDER BY p.price ASC
    -> LIMIT 1;
Empty set (0.01 sec) не были привязаны к поставщикам.

mysql> SELECT s.name, s.phone, p.productCode, p.price
    -> FROM products p
    -> LEFT JOIN products_suppliers ps ON p.productID = ps.productID
    -> LEFT JOIN suppliers s ON ps.supplierID = s.supplierID
    -> WHERE p.productCode = 'MRK'
    -> ORDER BY p.price ASC;
+------+-------+-------------+-------+
| name | phone | productCode | price |
+------+-------+-------------+-------+
| NULL | NULL  | MRK         |  2.49 |
| NULL | NULL  | MRK         |  2.49 |
+------+-------+-------------+-------+
2 rows in set (0.01 sec)

5*) Показать информацию о поставщике, который поставляет максимальное количество продукции по productCode:  

mysql> SELECT s.name, s.phone, p.productCode, SUM(p.quantity) AS TotalSupplied
    -> FROM products p
    -> JOIN products_suppliers ps ON p.productID = ps.productID
    -> JOIN suppliers s ON ps.supplierID = s.supplierID
    -> GROUP BY s.supplierID, p.productCode
    -> ORDER BY TotalSupplied DESC
    -> LIMIT 1;
+-------------+----------+-------------+---------------+
| name        | phone    | productCode | TotalSupplied |
+-------------+----------+-------------+---------------+
| ABC Traders | 88881111 | PEN         |         15000 |
+-------------+----------+-------------+---------------+
1 row in set (0.00 sec)             

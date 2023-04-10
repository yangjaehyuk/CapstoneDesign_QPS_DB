SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE DATABASE IF NOT EXISTS `qpsdb`;
USE `qpsdb`;

-- 테이블 작업

-- 제품 생성
CREATE TABLE IF NOT EXISTS `Product`(
Product_ID char(10) not NULL,
Product_cat char(10) default null,
primary key(Product_ID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 시뮬 생성
CREATE TABLE if not exists `Simulation`(
Simulation_ID char(10) NOT NULL,
Order_ID char(10) default null,
duration time default null,
primary key(Simulation_ID),
KEY `FK_Simulation_Order_ID` (`Order_ID`),
constraint `FK_Simulation_Order_ID` foreign key (`Order_ID`) references `Order` (`Order_ID`) ON DELETE SET NULL ON UPDATE cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 워크스테이션 생성
CREATE TABLE if not exists `WorkStation` (
WorkStation_IDX int not null auto_increment,
WorkStation_ID char(10) NOT NULL,
Product_ID char(10) default null,
Simulation_ID char(10) default null,
ToteBox_ID char(10) default null,
ToteBox_IDX int default null,
CurrentToteBoxCnt int default 0,
CurrentProductCnt int default null,
Employeecnt int default 0,
primary key(WorkStation_IDX, WorkStation_ID),
KEY `FK_WorkStation_Product_ID` (`Product_ID`),
KEY `FK_WorkStation_ToteBox_GROUP` (`ToteBox_IDX`,`ToteBox_ID`),
KEY `FK_WorkStation_Simulation_ID` (`Simulation_ID`),
CONSTRAINT `FK_WorkStation_Product_ID` FOREIGN KEY (`Product_ID`) REFERENCES `Product` (`Product_ID`) ON DELETE SET NULL ON UPDATE cascade,
constraint `FK_WorkStation_ToteBox_GROUP` foreign key (`ToteBox_IDX`,`ToteBox_ID`) references `ToteBox` (`ToteBox_IDX`,`ToteBox_ID`) ON DELETE CASCADE ON UPDATE cascade,
constraint `FK_WorkStation_Simulation_ID` foreign key (`Simulation_ID`) references `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 토트박스 생성
CREATE TABLE if not exists `ToteBox` (
ToteBox_IDX int not null auto_increment,
ToteBox_ID char(10) NOT null,
Product_ID CHAR(10) NOT NULL,
Order_ID char(10) default null,
Simulation_ID CHAR(10) DEFAULT NULL,
primary key(ToteBox_IDX, ToteBox_ID),
key `FK_ToteBox_Order_ID` (`Order_ID`),
KEY `FK_ToteBox_Simulation_ID` (`Simulation_ID`),
constraint `FK_ToteBox_Order_ID` foreign key (`Order_ID`) references `Order` (`Order_ID`) ON delete set null on update cascade,
constraint `FK_ToteBox_Simulation_ID` FOREIGN KEY (`Simulation_ID`) REFERENCES `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 오더 생성
CREATE TABLE if not exists `Order` (
Order_ID Char(30) NOT null,
Simulation_ID CHAR(10) DEFAULT NULL,
Product_ID char(10) default NULL,
Product_cnt INT default NULL,
Product_cat char(10) default null,
primary key(Order_ID),
KEY `FK_Order_Product_ID` (`Product_ID`),
KEY `FK_Order_Simulation_ID` (`Simulation_ID`),
constraint `FK_Order_Product_ID` foreign key (`Product_ID`) references `Product` (`Product_ID`) ON DELETE CASCADE ON UPDATE cascade,
CONSTRAINT `FK_Order_Simulation_ID` FOREIGN KEY (`Simulation_ID`) REFERENCES `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 결과
create table IF NOT EXISTS `Result`(
Simulation_ID CHAR(10) NOT NULL,
Total_time time default null,
PRIMARY KEY(Simulation_ID),
CONSTRAINT `FK_result_Simulation_ID` FOREIGN KEY (`Simulation_ID`) REFERENCES `Simulation` (`Simulation_ID`) ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 프로시저

-- 제품 생성
DELIMITER //
CREATE PROCEDURE `createProduct`(
	IN `qps_Product_ID` VARCHAR(50),
	IN `qps_Product_cat` VARCHAR(50)
)
BEGIN
INSERT INTO `Product`(Product_ID, Product_cat)
VALUES(qps_Product_ID, qps_Product_cat);
END//
DELIMITER ;

-- 토트박스 생성
DELIMITER //
CREATE PROCEDURE `createToteBox`(
	IN `qps_ToteBox_IDX` INT,
    IN `qps_ToteBox_ID` VARCHAR(50),
    IN `qps_Product_ID` VARCHAR(50),
    IN `qps_Order_ID` VARCHAR(50),
    IN `qps_Simulation_ID` VARCHAR(50)
)
BEGIN
DECLARE X CHAR(10);
DECLARE Y CHAR(10);
DECLARE Z INT;

SELECT `Order`.Order_ID INTO X
FROM `Order`
WHERE `Order`.Order_ID = qps_Order_ID;

SELECT `Order`.Product_ID INTO Y
FROM `Order`
WHERE `Order`.Product_ID = qps_Product_ID;

INSERT INTO ToteBox(ToteBox_IDX, ToteBox_ID, Product_ID, Order_ID, Simulation_ID) 
VALUES(qps_ToteBox_IDX, qps_ToteBox_ID, Y, X, qps_Simulation_ID);

UPDATE WorkStation
SET ToteBox_ID = qps_ToteBox_ID
WHERE Simulation_ID = qps_Simulation_ID;
END//
DELIMITER ;

-- INSERT INTO Product
-- values('2','어류');
-- select * from Product;
-- select * from `Order`;
-- call createToteBox(7,'14','1','6','1');
-- select * from `ToteBox`;
-- show create procedure createToteBox;
-- drop procedure createToteBox;

-- 오더 생성
DELIMITER //
CREATE PROCEDURE `createOrder`(
	IN `qps_Order_ID` VARCHAR(50),
    IN `qps_Simulation_ID` VARCHAR(50),
    IN `qps_Product_ID` VARCHAR(50),
    IN `qps_Product_cnt` int,
    IN `qps_Product_cat` varchar(50)
)
BEGIN
DECLARE SID VARCHAR(50);
DECLARE PID varchar(50);

SELECT `Simulation`.Simulation_ID into SID
FROM `Simulation`
Where `Simulation`.Simulation_ID = qps_Simulation_ID;

SELECT `Product`.Product_ID into PID
FROM `Product`
WHERE `Product`.Product_ID = qps_Product_ID;
INSERT INTO `Order`(Order_ID, Simulation_ID, Product_ID, Product_cnt, Product_cat)
VALUES(qps_Order_ID, SID, PID, qps_Product_cnt, qps_Product_cat);

END//
DELIMITER ;
-- call createProduct('1','가전');
-- call createOrder('6','2','1',3,'가전');
-- select * from `Product`;
-- select * from `Order`;
-- -- show create procedure createOrder;
-- drop procedure createOrder;

-- 시뮬레이션 생성
DELIMITER //
CREATE PROCEDURE `createSimul`(
	IN `qps_Simulation_ID` VARCHAR(50),
    IN `qps_Order_ID` VARCHAR(50)
)
BEGIN
DECLARE X CHAR(10);
SELECT `Order`.Order_ID INTO X
FROM `Order`
Where `Order`.Order_ID = qps_Order_ID;

INSERT INTO Simulation(Simulation_ID, Order_ID) 
VALUES(qps_Simulation_ID, X);
END//
DELIMITER ;

-- call createSimul('2','1');
-- select * from `Simulation`;
-- drop procedure createSimul;


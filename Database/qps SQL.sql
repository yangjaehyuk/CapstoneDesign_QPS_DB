SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE DATABASE IF NOT EXISTS `qps`;
USE `qps`;

-- 테이블 작업

-- 제품 생성
CREATE TABLE IF NOT EXISTS `Product`(
Product_ID char(10) not NULL,
Product_cnt INT DEFAULT 0,
Product_cat char(10) default null,
primary key(Product_ID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 시뮬 생성
CREATE TABLE if not exists `Simulation`(
Simulation_ID char(10) NOT NULL,
ToteBox_ID char(10) default NULL,
ToteBox_IDX int default null,
timer TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, #speed 를 timer로 수정
primary key(Simulation_ID),
KEY `FK_Simulation_ToteBox_GROUP` (`ToteBox_IDX`,`ToteBox_ID`),
constraint `FK_Simulation_ToteBox_GROUP` foreign key (`ToteBox_IDX`,`ToteBox_ID`) references `ToteBox` (`ToteBox_IDX`,`ToteBox_ID`) ON DELETE CASCADE ON UPDATE cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 워크스테이션 생성
CREATE TABLE if not exists `WorkStation` (
WorkStation_IDX int not null auto_increment,
WorkStation_ID char(10) NOT NULL,
Simulation_ID char(10) default null,
ToteBox_ID char(10) default null,
ToteBox_IDX int default null,
CurrentToteBoxCnt int default 0,
CurrentProductCnt int default null,
Employeecnt int default 0,
primary key(WorkStation_IDX, WorkStation_ID),
key `FK_WorkStation_Simulation_ID` (`Simulation_ID`),
KEY `FK_WorkStation_ToteBox_GROUP` (`ToteBox_IDX`,`ToteBox_ID`),
constraint `FK_WorkStation_Simulation_ID` foreign key (`Simulation_ID`) references `Simulation` (`Simulation_ID`) ON delete set null on update cascade,
constraint `FK_WorkStation_ToteBox_GROUP` foreign key (`ToteBox_IDX`,`ToteBox_ID`) references `ToteBox` (`ToteBox_IDX`,`ToteBox_ID`) ON DELETE CASCADE ON UPDATE cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 토트박스 생성
CREATE TABLE if not exists `ToteBox` (
ToteBox_IDX int not null auto_increment,
ToteBox_ID char(10) NOT null,
WorkStation_IDX int default null,
WorkStation_ID char(10) default NULL,
Simulation_ID char(10) default null,
primary key(ToteBox_IDX, ToteBox_ID),
KEY `FK_ToteBox_WorkStation_GROUP` (`WorkStation_IDX`,`WorkStation_ID`),
key `FK_ToteBox_Simulation_ID` (`Simulation_ID`),
constraint `FK_ToteBox_WorkStation_GROUP` foreign key (`WorkStation_IDX`,`WorkStation_ID`) references `WorkStation` (`WorkStation_IDX`,`WorkStation_ID`) ON DELETE CASCADE ON UPDATE cascade,
constraint `FK_ToteBox_Simulation_ID` foreign key (`Simulation_ID`) references `Simulation` (`Simulation_ID`) ON delete set null on update cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 오더 생성
CREATE TABLE if not exists `Order` (
Order_ID Char(30) NOT null,
WorkStation_ID Char(10) default NULL,
WorkStation_IDX int default null,
ToteBox_ID char(10) default NULL,
ToteBox_IDX int default null,
Simulation_ID char(10) default NULL,
Product_ID char(10) default NULL,
Product_cnt INT default NULL,
Product_cat char(10) default null,
primary key(Order_ID),
KEY `FK_Order_WorkStation_GROUP` (`WorkStation_IDX`,`WorkStation_ID`),
KEY `FK_Order_ToteBox_GROUP` (`ToteBox_IDX`,`ToteBox_ID`),
KEY `FK_Order_Simulation_ID` (`Simulation_ID`),
KEY `FK_Order_Product_ID` (`Product_ID`),
Constraint `FK_Order_WorkStation_GROUP` foreign key (`WorkStation_IDX`,`WorkStation_ID`) references `WorkStation` (`WorkStation_IDX`,`WorkStation_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
constraint `FK_Order_ToteBox_GROUP` foreign key (`ToteBox_IDX`,`ToteBox_ID`) references `ToteBox` (`ToteBox_IDX`,`ToteBox_ID`) ON DELETE CASCADE ON UPDATE cascade,
constraint `FK_Order_Simulation_ID` foreign key (`Simulation_ID`) references `Simulation` (`Simulation_ID`) ON DELETE set null on update cascade,
constraint `FK_Order_Product_ID` foreign key (`Product_ID`) references `Product` (`Product_ID`) ON DELETE CASCADE ON UPDATE cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 프로시저

-- 제품 생성
DELIMITER //
CREATE PROCEDURE `createProduct`(
	IN `qps_Product_ID` VARCHAR(50),
	IN `qps_Product_cnt` INT,
	IN `qps_Product_cat` VARCHAR(50)
)
BEGIN
INSERT INTO `Product`(Product_ID, Product_cnt, Product_cat)
VALUES(qps_Product_ID, qps_Product_cnt, qps_Product_cat);
END//
DELIMITER ;

call createProduct('5',3,'가전');
select * from `Product`;
drop procedure createProduct;

-- 오더 생성
DELIMITER //
CREATE PROCEDURE `createOrder`(
	IN `qps_Order_ID` VARCHAR(50),
	IN `qps_WorkStation_ID` VARCHAR(50),
	IN `qps_ToteBox_ID` VARCHAR(50),
	IN `qps_Simulation_ID` VARCHAR(50),
    IN `qps_Product_ID` VARCHAR(50)
)
BEGIN
DECLARE Pcnt INT;
DECLARE Pcat char(10);
SELECT Product.Product_cnt INTO Pcnt
FROM Product
WHERE Product.Product_ID = qps_Product_ID;
SELECT Product.Product_cat INTO Pcat
FROM Product
WHERE Product.Product_ID = qps_Product_ID;

INSERT INTO `Order`(Order_ID, WorkStation_ID, ToteBox_ID, Simulation_ID, Product_ID, Product_cnt, Product_cat)
VALUES(qps_Order_ID, qps_WorkStation_ID, qps_ToteBox_ID, qps_Simulation_ID, qps_Product_ID, Pcnt, Pcat);

END//
DELIMITER ;

call createOrder('6','2','3','4','5');
select * from `Order`;
show create procedure createOrder;
drop procedure createOrder;

-- 토트박스 생성
DELIMITER //
CREATE PROCEDURE `createToteBox`(
	IN `qps_ToteBox_IDX` INT,
	IN `qps_ToteBox_ID` VARCHAR(50),
	IN `qps_Simulation_ID` VARCHAR(50),
    IN `qps_WorkStation_ID` VARCHAR(50)
)
BEGIN
DECLARE X CHAR(10);
SELECT WorkStation.ToteBox_ID INTO X
FROM WorkStation
WHERE WorkStation.ToteBox_ID = qps_ToteBox_ID;

INSERT INTO ToteBox(ToteBox_IDX, ToteBox_ID, Simulation_ID, WorkStation_ID) 
VALUES(qps_ToteBox_IDX, qps_ToteBox_ID, qps_Simulation_ID, qps_WorkStation_ID);

UPDATE WorkStation
SET ToteBox_ID = qps_ToteBox_ID
WHERE Simulation_ID = qps_Simulation_ID and WorkStation.ToteBox_ID = X;
END//
DELIMITER ;

call createToteBox(1,'1','1','1');
call createToteBox(1,'2','2','2');
call createToteBox(1,'3','3','3');
call createToteBox(1,'4','3','3');
select * from `ToteBox`;
show create procedure createToteBox;
drop procedure createToteBox;
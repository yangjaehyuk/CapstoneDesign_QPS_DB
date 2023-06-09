SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE DATABASE IF NOT EXISTS `qps`;
USE `qps`;

-- 테이블 작업

-- 제품 생성
CREATE TABLE IF NOT EXISTS `Product`(
Product_ID char(20) not NULL,
Product_cat char(10) default null,
primary key(Product_ID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*
-- 제품 데이터 삽입 
LOAD DATA INFILE '/var/lib/mysql/product.csv'  
INTO TABLE `Product`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_ID, Product_cat);
*/
-- 시뮬 생성
CREATE TABLE if not exists `Simulation`(
Simulation_ID char(10) NOT NULL,
Order_IDX INT DEFAULT NULL,
Order_ID char(10) default null,
start_time time default null,
end_time time default null,
duration time default null,
primary key(Simulation_ID),
KEY `FK_Simulation_Order_GROUP` (`Order_IDX`,`Order_ID`),
constraint `FK_Simulation_Order_GROUP` foreign key (`Order_IDX`, `Order_ID`) references `Order` (`Order_IDX`, `Order_ID`) ON DELETE SET NULL ON UPDATE cascade
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 워크스테이션 생성
CREATE TABLE if not exists `WorkStation` (
WorkStation_IDX int not null,
WorkStation_ID char(10) NOT NULL,
Product_ID char(20) default null,
Simulation_ID char(10) default null,
ToteBox_IDX INT DEFAULT NULL,
ToteBox_ID char(10) default null,
primary key(WorkStation_IDX, WorkStation_ID),
KEY `FK_WorkStation_Product_ID` (`Product_ID`),
KEY `FK_WorkStation_ToteBox_GROUP` (`ToteBox_IDX`, `ToteBox_ID`),
KEY `FK_WorkStation_Simulation_ID` (`Simulation_ID`),
CONSTRAINT `FK_WorkStation_Product_ID` FOREIGN KEY (`Product_ID`) REFERENCES `Product` (`Product_ID`) ON DELETE SET NULL ON UPDATE cascade,
constraint `FK_WorkStation_ToteBox_GROUP` foreign key (`ToteBox_IDX`, `ToteBox_ID`) references `ToteBox` (`ToteBox_IDX`, `ToteBox_ID`) ON DELETE CASCADE ON UPDATE cascade,
constraint `FK_WorkStation_Simulation_ID` foreign key (`Simulation_ID`) references `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 토트박스 생성
CREATE TABLE if not exists `ToteBox` (
ToteBox_IDX INT NOT NULL,
ToteBox_ID char(10) NOT null,
WorkStation_IDX int default null,
WorkStation_ID CHAR(10) DEFAULT NULL,
Product_ID CHAR(20) DEFAULT NULL,
Order_IDX INT  DEFAULT NULL,
Order_ID char(10) default null,
Simulation_ID CHAR(10) DEFAULT NULL,
primary key(ToteBox_IDX, ToteBox_ID),
key `FK_ToteBox_Order_GROUP` (`Order_IDX`, `Order_ID`),
KEY `FK_ToteBox_Simulation_ID` (`Simulation_ID`),
KEY `FK_ToteBox_WorkStation_GROUP` (`WorkStation_IDX`, `WorkStation_ID`),
constraint `FK_ToteBox_Order_GROUP` foreign key (`Order_IDX`, `Order_ID`) references `Order` (`Order_IDX`, `Order_ID`) ON delete set null on update cascade,
constraint `FK_ToteBox_Simulation_ID` FOREIGN KEY (`Simulation_ID`) REFERENCES `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE,
CONSTRAINT `FK_ToteBox_WorkStation_GROUP` FOREIGN KEY (`WorkStation_IDX`, `WorkStation_ID`) REFERENCES `WorkStation` (`WorkStation_IDX`, `WorkStation_ID`) ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 오더 생성
CREATE TABLE if not exists `Order` (
Order_IDX INT NOT NULL,
Order_ID Char(30) NOT null,
Simulation_ID CHAR(10) DEFAULT NULL,
Product_ID char(20) default NULL,
Product_cnt INT default NULL,
Product_cat char(10) default null,
primary key(Order_IDX, Order_ID),
KEY `FK_Order_Product_ID` (`Product_ID`),
KEY `FK_Order_Simulation_ID` (`Simulation_ID`),
constraint `FK_Order_Product_ID` foreign key (`Product_ID`) references `Product` (`Product_ID`) ON DELETE CASCADE ON UPDATE cascade,
CONSTRAINT `FK_Order_Simulation_ID` FOREIGN KEY (`Simulation_ID`) REFERENCES `Simulation` (`Simulation_ID`) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 워크스테이션 내 토트 박스 테이블
CREATE TABLE if not exists `ToteBoxInWorkStation` (
LOG_ID INT DEFAULT NULL,
ToteBox_IDX INT default NULL,
ToteBox_ID char(10) default null,
WorkStation_IDX int default null,
WorkStation_ID CHAR(10) DEFAULT NULL,
entry_time time default null,
KEY `FK_ToteBoxInWorkStation_ToteBox_GROUP` (`ToteBox_IDX`, `ToteBox_ID`),
KEY `FK_ToteBoxInWorkStation_WorkStation_GROUP` (`WorkStation_IDX`, `WorkStation_ID`),
CONSTRAINT `FK_ToteBoxInWorkStation_ToteBox_GROUP` FOREIGN KEY (`ToteBox_IDX`, `ToteBox_ID`) REFERENCES `ToteBox` (`ToteBox_IDX`, `ToteBox_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT `FK_ToteBoxInWorkStation_WorkStation_GROUP` FOREIGN KEY (`WorkStation_IDX`, `WorkStation_ID`) REFERENCES `WorkStation` (`WorkStation_IDX`, `WorkStation_ID`) ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 프로시저

-- 제품 생성
-- DELIMITER //
-- CREATE PROCEDURE `createProduct`(
-- 		IN `qps_Product_ID` VARCHAR(50),
-- 		IN `qps_Product_cat` VARCHAR(50)
-- )
-- BEGIN
-- INSERT INTO `Product`(Product_ID, Product_cat)
-- VALUES(qps_Product_ID, qps_Product_cat);
-- END //
-- DELIMITER ;

-- 토트박스 생성
-- DELIMITER //
-- CREATE PROCEDURE `createToteBox`(
-- 	   IN `qps_ToteBox_IDX` INT,
--     IN `qps_ToteBox_ID` VARCHAR(50),
--     IN `qps_Product_ID` VARCHAR(50),
--     IN `qps_Order_IDX` INT,
--     IN `qps_Order_ID` VARCHAR(50),
--     IN `qps_Simulation_ID` VARCHAR(50)
-- )
-- BEGIN
-- INSERT INTO ToteBox(ToteBox_IDX, ToteBox_ID, Product_ID, Order_IDX, Order_ID, Simulation_ID)
-- VALUES(qps_ToteBox_IDX, qps_ToteBox_ID, qps_Product_ID, qps_Order_IDX, qps_Order_ID, qps_Simulation_ID);
-- END //
-- DELIMITER ;

-- 오더 생성
-- DELIMITER //
-- CREATE PROCEDURE `createOrder`(
-- 	   IN `qps_Order_IDX` INT,
-- 	   IN `qps_Order_ID` VARCHAR(50),
--     IN `qps_Simulation_ID` VARCHAR(50),
--     IN `qps_Product_ID` VARCHAR(50),
--     IN `qps_Product_cnt` int,
--     IN `qps_Product_cat` varchar(50)
-- )
-- BEGIN
-- INSERT INTO `Order`(Order_IDX, Order_ID, Simulation_ID, Product_ID, Product_cnt, Product_cat)
-- VALUES(qps_Order_IDX ,qps_Order_ID, qps_Simulation_ID, qps_Product_ID, qps_Product_cnt, qps_Product_cat);
-- END //
-- DELIMITER ;

-- 시뮬레이션 생성
-- DELIMITER //
-- CREATE PROCEDURE `createSimul`(
-- 	   IN `qps_Simulation_ID` VARCHAR(50),
--     IN `qps_Order_IDX` INT,
--     IN `qps_Order_ID` VARCHAR(50)
-- )
-- BEGIN
-- INSERT INTO Simulation(Simulation_ID, Order_IDX, Order_ID)
-- VALUES (qps_Simulation_ID, qps_Order_IDX, qps_Order_ID);
-- END //
-- DELIMITER ;

-- 워크스테이션 생성
-- DELIMITER //
-- CREATE PROCEDURE `createWorkStation`(
--     IN `qps_WorkStation_IDX` INT,
--     IN `qps_WorkStation_ID` VARCHAR(50),
--     IN `qps_Product_ID` VARCHAR(50),
--     IN `qps_Simulation_ID` VARCHAR(50)
-- )
-- BEGIN
-- INSERT INTO WorkStation(WorkStation_IDX, WorkStation_ID, Product_ID, Simulation_ID) 
-- VALUES(qps_WorkStation_IDX, qps_WorkStation_ID, qps_Product_ID, qps_Simulation_ID);
-- END //
-- DELIMITER ;

-- 토트박스가 워크스테이션에 진입했을 때 워크스테이션 내 토트박스 정보 기록
DELIMITER //
CREATE PROCEDURE `CheckToteBox`(
    IN `qps_WorkStation_ID` VARCHAR(50),
    IN `qps_ToteBox_ID` VARCHAR(50)
)
BEGIN
DECLARE t TIME;
DECLARE ID INT;
SET t=NOW();
IF ID = NULL THEN
SET ID = 0;
ELSE
SET ID=ID+1;
END IF;
INSERT INTO ToteBoxInWorkStation(WorkStation_ID, ToteBox_ID, entry_time)
VALUES(qps_WorkStation_ID, qps_ToteBox_ID, t); 
END //
DELIMITER ;

-- select * from WorkStation;
-- select * from ToteBox;
-- select * from ToteBoxInWorkStation;
-- call CheckToteBox('ws01','4');
-- drop procedure checkToteBox;

-- 워크스테이션 내 현재 토트박스 개수 확인
DELIMITER //
CREATE PROCEDURE `CountToteBox`(
	IN `qps_WorkStation_ID` VARCHAR(50)
)
BEGIN
    DECLARE min_time TIME;
    
    SELECT MIN(entry_time) INTO min_time FROM ToteBoxInWorkStation WHERE WorkStation_ID = qps_WorkStation_ID;
    
    SELECT WorkStation_ID, COUNT(*) AS ToteBox_CNT
    FROM ToteBoxInWorkStation
    WHERE TIMEDIFF(entry_time, min_time) <= '00:00:05';
END //
DELIMITER ;


select * from ToteBoxInWorkStation;
call CountToteBox('ws01');
drop procedure CountToteBox;

-- 시뮬레이션 시작 시간
DELIMITER //
CREATE PROCEDURE `startSimul`(
	IN `qps_Simulation_ID` VARCHAR(50)
)
BEGIN
UPDATE Simulation SET start_time = NOW() WHERE Simulation_ID=qps_Simulation_ID;
END //
DELIMITER ;

-- 시뮬레이션 종료 시간
DELIMITER //
CREATE PROCEDURE `endSimul`(
	IN `qps_Simulation_ID` VARCHAR(50)
)
BEGIN
UPDATE Simulation SET end_time = NOW() WHERE Simulation_ID=qps_Simulation_ID;
END //
DELIMITER ;

-- call startSimul('2');
-- call endSimul('2');
-- select * from Simulation;
-- drop procedure startSimul;
-- drop procedure endSimul;
-- 시뮬레이션 끝난 후 진행 시간 기록
DELIMITER //
CREATE PROCEDURE `updateResult`(
	IN `qps_Simulation_ID` VARCHAR(50)
)
BEGIN
UPDATE Simulation SET duration=TIMEDIFF(Simulation.end_time, Simulation.start_time) WHERE Simulation_ID=qps_Simulation_ID;
END //
DELIMITER ;

-- call updateResult('1');
-- select * from Simulation;
-- drop procedure updateResult;

-- 오더 삭제
-- DELIMITER //
-- CREATE PROCEDURE `deleteOrder`(
-- 	IN `qps_Simulation_ID` VARCHAR(50),
--     IN `qps_Order_IDX` INT,
--     IN `qps_Order_ID` VARCHAR(50)
-- )
-- BEGIN
-- DELETE FROM `Order`
-- WHERE Simulation_ID = qps_Simulation_ID and Order_IDX = qps_Order_IDX and Order_ID = qps_Order_ID;
-- END //
-- DELIMITER ;

-- 워크스테이션 삭제
-- DELIMITER //
-- CREATE PROCEDURE `deleteWorkStation`(
-- 	IN `qps_Simulation_ID` VARCHAR(50),
--     IN `qps_WorkStation_IDX` INT,
--     IN `qps_WorkStation_ID` VARCHAR(50)
-- )
-- BEGIN
-- DELETE FROM WorkStation
-- WHERE Simulation_ID = qps_Simulation_ID and WorkStation_ID = qps_WorkStation_ID and WorkStationIDX = qps_WorkStation_IDX;
-- END //
-- DELIMITER ;

-- 토트박스 삭제
-- DELIMITER //
-- CREATE PROCEDURE `deleteToteBox`(
-- 	IN `qps_Simulation_ID` VARCHAR(50),
--     IN `qps_ToteBox_IDX` INT,
--     IN `qps_ToteBox_ID` VARCHAR(50)
-- )
-- BEGIN
-- DELETE FROM ToteBox
-- WHERE Simulation_ID = qps_Simulation_ID and ToteBox_ID = qps_ToteBox_IDX and ToteBox_IDX = qps_ToteBox_ID;
-- END //
-- DELIMITER ;

-- 시뮬레이션 삭제
-- DELIMITER //
-- CREATE PROCEDURE `deleteSimulation`(
-- 	IN `qps_Simulation_ID` VARCHAR(50)
-- )
-- BEGIN
-- DELETE FROM Simulation
-- WHERE Simulation_ID = qps_Simulation_ID;
-- END //
-- DELIMITER ;

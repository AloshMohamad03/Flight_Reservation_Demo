-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Dec 17, 2025 at 08:16 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flight_reservation`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `AddAirport`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAirport` (IN `a_code` VARCHAR(10), IN `a_name` VARCHAR(100), IN `city` VARCHAR(100), IN `country` VARCHAR(100))   BEGIN
   INSERT INTO Airport(AirportCode, Name, City, Country)
   VALUES(a_code, a_name, city, country);
END$$

DROP PROCEDURE IF EXISTS `AddFlight`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddFlight` (`flight_num` VARCHAR(20), `depID` INT, `arrID` INT, `dep` DATETIME, `arr` DATETIME, `airline` VARCHAR(100), `aircraft` VARCHAR(100), `seats` INT)   BEGIN
   INSERT INTO Flight(
      FlightNumber, DepAirportID, ArrAirportID,
      DepTime, ArrTime, Airline, AirCraftType, TotalSeats
   )
   VALUES(flight_num, depID, arrID, dep, arr, airline, aircraft, seats);
END$$

DROP PROCEDURE IF EXISTS `CountFlights`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CountFlights` (OUT `totalF` INT)   BEGIN
   SELECT COUNT(*) INTO totalF
   FROM Flight;
END$$

DROP PROCEDURE IF EXISTS `DeleteFlight`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteFlight` (`flight_ID` INT)   BEGIN
   DELETE FROM Fare WHERE FlightID = flight_ID;
   DELETE FROM Flight WHERE FlightID = flight_ID;
END$$

DROP PROCEDURE IF EXISTS `GetFlightFares`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFlightFares` (`flight_ID` INT)   BEGIN
   SELECT FareID, ClassType, Price, AvailableSeats
   FROM Fare
   WHERE FlightID = flight_ID;
END$$

DROP PROCEDURE IF EXISTS `List_Airports`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `List_Airports` ()   BEGIN
DECLARE v_finished INT DEFAULT 0;
DECLARE v_AirportID INT;
DECLARE v_AirportCode VARCHAR(10);
DECLARE v_Name VARCHAR(100);
DECLARE airport_cursor CURSOR FOR 
SELECT AirportID, AirportCode, Name FROM Airport;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;

OPEN airport_cursor;

 a_loop: LOOP
FETCH airport_cursor INTO v_AirportID, v_AirportCode, v_Name;

IF v_finished = 1 THEN
LEAVE a_loop;
END IF;

SELECT v_AirportID AS airportID,
v_AirportCode AS airportCode,
v_Name AS AirportName;
END LOOP;
CLOSE airport_cursor;
END$$

DROP PROCEDURE IF EXISTS `List_Customers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `List_Customers` ()   BEGIN
DECLARE v_finished INT DEFAULT 0;
DECLARE v_FirstName VARCHAR(100);
DECLARE v_LastName VARCHAR(100);
DECLARE v_Email VARCHAR(150);

DECLARE customer_cursor CURSOR FOR
SELECT FirstName, LastName, Email FROM Customer;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
OPEN customer_cursor;
c_loop: LOOP
FETCH customer_cursor INTO v_FirstName, v_LastName, v_Email;
IF v_finished = 1 THEN
LEAVE c_loop;
END IF;

SELECT CONCAT(v_FirstName,' ',v_LastName) AS FullName,
v_Email AS Email;
 END LOOP;

CLOSE customer_cursor;
END$$

DROP PROCEDURE IF EXISTS `List_Fares`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `List_Fares` ()   BEGIN
DECLARE v_finished INT DEFAULT 0;
DECLARE v_ClassType ENUM('Economy','Business','First');
DECLARE v_Price FLOAT;
DECLARE v_AvailableSeats INT;

DECLARE fare_cursor CURSOR FOR
SELECT ClassType, Price, AvailableSeats FROM Fare;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
OPEN fare_cursor;
f_loop: LOOP
FETCH fare_cursor INTO v_ClassType, v_Price, v_AvailableSeats;
IF v_finished = 1 THEN
LEAVE f_loop;
END IF;
SELECT v_ClassType AS Class,
       v_Price AS Price,
       v_AvailableSeats AS availableSeats;
END LOOP;
CLOSE fare_cursor;
END$$

DROP PROCEDURE IF EXISTS `ShowAllFlights`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowAllFlights` ()   BEGIN
   SELECT FlightID, FlightNumber, DepTime, ArrTime, Airline
   FROM Flight;
END$$

DROP PROCEDURE IF EXISTS `UpdateCustomerInfo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCustomerInfo` (`id` INT, `fn` VARCHAR(100), `ln` VARCHAR(100), `pwd` VARCHAR(255), `em` VARCHAR(150), `phone` VARCHAR(20))   BEGIN
   UPDATE Customer
   SET FirstName = fn,
       LastName = ln,
       Passward = pwd,
       Email = em,
       PhoneNumber = phone
   WHERE CustomerID = id;
END$$

DROP PROCEDURE IF EXISTS `UpdateFareClassType`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateFareClassType` (IN `p_FareID` INT, IN `p_Class` ENUM('Economy','Business','First'))   BEGIN
    UPDATE Fare
    SET ClassType = p_Class
    WHERE FareID = p_FareID;
END$$

DROP PROCEDURE IF EXISTS `UpdatePaymentStatus`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePaymentStatus` (IN `p_BookingID` INT, IN `p_Status` ENUM('Pending','Paid'))   BEGIN
    UPDATE Booking
    SET PaymentStatus = p_Status
    WHERE BookingID = p_BookingID;
END$$

DROP PROCEDURE IF EXISTS `UpdateTicketStatus`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateTicketStatus` (IN `p_TicketID` INT, IN `p_Status` ENUM('Confirmed','Cancelled'))   BEGIN
    UPDATE Ticket
    SET TicketStatus = p_Status
    WHERE TicketID = p_TicketID;
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `CountTickets`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `CountTickets` (`booking_ID` INT) RETURNS INT  BEGIN
   DECLARE c INT;

   SELECT COUNT(*) INTO c
   FROM Ticket
   WHERE BookingID = booking_ID;

   RETURN c;
END$$

DROP FUNCTION IF EXISTS `GetClassType`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetClassType` (`p_FareID` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE c VARCHAR(20);

    SELECT ClassType
    INTO c
    FROM Fare
    WHERE FareID = p_FareID;

    RETURN c;
END$$

DROP FUNCTION IF EXISTS `GetPaymentStatus`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetPaymentStatus` (`p_BookingID` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE s VARCHAR(20);

    SELECT PaymentStatus
    INTO s
    FROM Booking
    WHERE BookingID = p_BookingID;

    RETURN s;
END$$

DROP FUNCTION IF EXISTS `GetTicketStatus`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetTicketStatus` (`p_TicketID` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE t VARCHAR(20);

    SELECT TicketStatus
    INTO t
    FROM Ticket
    WHERE TicketID = p_TicketID;

    RETURN t;
END$$

DROP FUNCTION IF EXISTS `SeatsAvailable`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `SeatsAvailable` (`fare_ID` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
   DECLARE a INT;
   DECLARE result VARCHAR(20);

   SELECT AvailableSeats INTO a
   FROM Fare
   WHERE FareID = fare_ID;

   IF a > 0 THEN
      SET result = 'Available';
   ELSE
      SET result = 'Full';
   END IF;
   RETURN result;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `airport`
--

DROP TABLE IF EXISTS `airport`;
CREATE TABLE IF NOT EXISTS `airport` (
  `AirportID` int NOT NULL AUTO_INCREMENT,
  `AirportCode` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Name` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `City` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Country` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`AirportID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `airport`
--

INSERT INTO `airport` (`AirportID`, `AirportCode`, `Name`, `City`, `Country`) VALUES
(1, 'JFK', 'John F. Kennedy International Airport', 'New York', 'USA'),
(2, 'LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA'),
(3, 'CDG', 'Charles de Gaulle Airport', 'Paris', 'France'),
(4, 'FCO', 'Leonardo da Vinci–Fiumicino Airport', 'Rome', 'Italy'),
(5, 'LHR', 'London Heathrow Airport', 'London', 'UK');

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
CREATE TABLE IF NOT EXISTS `booking` (
  `BookingID` int NOT NULL AUTO_INCREMENT,
  `CustomerID` int DEFAULT NULL,
  `BookingDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `TotalAmount` float DEFAULT NULL,
  `PaymentStatus` enum('Pending','Paid') COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`BookingID`),
  KEY `CustomerID` (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`BookingID`, `CustomerID`, `BookingDate`, `TotalAmount`, `PaymentStatus`) VALUES
(1, 1, '2025-11-24 22:15:43', 500, 'Paid'),
(2, 2, '2025-11-24 22:15:43', 450, 'Pending'),
(3, 3, '2025-11-24 22:15:43', 300, 'Paid'),
(4, 4, '2025-11-24 22:15:43', 250, 'Paid'),
(5, 5, '2025-11-24 22:15:43', 350, 'Pending');

--
-- Triggers `booking`
--
DROP TRIGGER IF EXISTS `reservation_del_trigger`;
DELIMITER $$
CREATE TRIGGER `reservation_del_trigger` AFTER DELETE ON `booking` FOR EACH ROW BEGIN
INSERT INTO reservation_del_log
VALUES (OLD.BookingID, CURRENT_TIMESTAMP);
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `reservation_trigger`;
DELIMITER $$
CREATE TRIGGER `reservation_trigger` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
INSERT INTO reservation_log
VALUES (NEW.BookingID, CURRENT_TIMESTAMP);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE IF NOT EXISTS `customer` (
  `CustomerID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LastName` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Passward` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Email` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `PhoneNumber` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`CustomerID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`CustomerID`, `FirstName`, `LastName`, `Passward`, `Email`, `PhoneNumber`) VALUES
(1, 'Hadi', 'Moustafa', 'pass44', 'Hadi@mail.com', '555-9999'),
(2, 'Hadi', 'Mohammed', 'pass234', 'Hadi2@Gmail.com', '555-2000'),
(3, 'Ali', 'Mahmoud', 'pass345', 'Ali@Gmail.com', '555-3000'),
(4, 'Maya', 'Mohammed', 'pass456', 'Maya@Gmail.com', '555-4000'),
(5, 'Hanin', 'Hasan', 'pass567', 'Hanin@Gmail.com', '555-5000');

-- --------------------------------------------------------

--
-- Table structure for table `fare`
--

DROP TABLE IF EXISTS `fare`;
CREATE TABLE IF NOT EXISTS `fare` (
  `FareID` int NOT NULL AUTO_INCREMENT,
  `FlightID` int DEFAULT NULL,
  `ClassType` enum('Economy','Business','First') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `AvailableSeats` int DEFAULT NULL,
  PRIMARY KEY (`FareID`),
  KEY `FlightID` (`FlightID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fare`
--

INSERT INTO `fare` (`FareID`, `FlightID`, `ClassType`, `Price`, `AvailableSeats`) VALUES
(1, 1, 'First', 500, 200),
(2, 2, 'Business', 900, 40),
(3, 3, 'First', 1500, 20),
(4, 4, 'Economy', 250, 120),
(5, 5, 'Business', 700, 60);

-- --------------------------------------------------------

--
-- Stand-in structure for view `fareflightdurationview`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `fareflightdurationview`;
CREATE TABLE IF NOT EXISTS `fareflightdurationview` (
`FareID` int
,`ClassType` enum('Economy','Business','First')
,`Price` float
,`AvailableSeats` int
,`FlightNumber` varchar(20)
,`Duration` int
);

-- --------------------------------------------------------

--
-- Table structure for table `flight`
--

DROP TABLE IF EXISTS `flight`;
CREATE TABLE IF NOT EXISTS `flight` (
  `FlightID` int NOT NULL AUTO_INCREMENT,
  `FlightNumber` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DepAirportID` int DEFAULT NULL,
  `ArrAirportID` int DEFAULT NULL,
  `DepTime` datetime DEFAULT NULL,
  `ArrTime` datetime DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `Airline` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `AirCraftType` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TotalSeats` int DEFAULT NULL,
  PRIMARY KEY (`FlightID`),
  KEY `DepAirportID` (`DepAirportID`),
  KEY `ArrAirportID` (`ArrAirportID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flight`
--

INSERT INTO `flight` (`FlightID`, `FlightNumber`, `DepAirportID`, `ArrAirportID`, `DepTime`, `ArrTime`, `Duration`, `Airline`, `AirCraftType`, `TotalSeats`) VALUES
(1, 'BA100', 5, 1, '2025-01-10 08:00:00', '2025-01-10 11:00:00', 420, 'British Airways', 'Boeing 777', 300),
(2, 'BA200', 5, 2, '2025-01-11 09:00:00', '2025-01-11 17:00:00', 600, 'British Airways', 'Airbus A380', 350),
(3, 'BA300', 5, 3, '2025-01-12 07:00:00', '2025-01-12 10:00:00', 180, 'British Airways', 'Airbus A320', 180),
(4, 'BA400', 5, 4, '2025-01-13 06:00:00', '2025-01-13 09:00:00', 180, 'British Airways', 'Boeing 737', 160),
(5, 'BA500', 5, 5, '2025-01-14 12:00:00', '2025-01-14 14:00:00', 120, 'British Airways', 'Boeing 787', 250);

-- --------------------------------------------------------

--
-- Stand-in structure for view `flightarrivalview`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `flightarrivalview`;
CREATE TABLE IF NOT EXISTS `flightarrivalview` (
`FlightID` int
,`FlightNumber` varchar(20)
,`ArrAirportID` int
,`ArrivalAirport` varchar(100)
,`ArrivalCity` varchar(100)
,`ArrivalCountry` varchar(100)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `flightdepartureview`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `flightdepartureview`;
CREATE TABLE IF NOT EXISTS `flightdepartureview` (
`FlightID` int
,`FlightNumber` varchar(20)
,`DepAirportID` int
,`DepartureAirport` varchar(100)
,`DepartureCity` varchar(100)
,`DepartureCountry` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `reservation_del_log`
--

DROP TABLE IF EXISTS `reservation_del_log`;
CREATE TABLE IF NOT EXISTS `reservation_del_log` (
  `BookingID` int DEFAULT NULL,
  `DeleteDate` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reservation_log`
--

DROP TABLE IF EXISTS `reservation_log`;
CREATE TABLE IF NOT EXISTS `reservation_log` (
  `BookingID` int DEFAULT NULL,
  `ActionDate` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

DROP TABLE IF EXISTS `ticket`;
CREATE TABLE IF NOT EXISTS `ticket` (
  `TicketID` int NOT NULL AUTO_INCREMENT,
  `BookingID` int DEFAULT NULL,
  `FareID` int DEFAULT NULL,
  `PassengerFirstName` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `PassengerLastName` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `PassportNumber` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `SeatNumber` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TicketStatus` enum('Confirmed','Cancelled') COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`TicketID`),
  KEY `BookingID` (`BookingID`),
  KEY `FareID` (`FareID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`TicketID`, `BookingID`, `FareID`, `PassengerFirstName`, `PassengerLastName`, `PassportNumber`, `SeatNumber`, `TicketStatus`) VALUES
(1, 1, 1, 'Hadi', 'Moustafa', 'A123456', '12A', 'Cancelled'),
(2, 2, 2, 'Hadi', 'Mohammed', 'B234567', '14C', 'Confirmed'),
(3, 3, 3, 'Ali', 'Mahmoud', 'C345678', '20B', 'Confirmed'),
(4, 4, 4, 'Maya', 'Mohammed', 'D456789', '18D', 'Confirmed'),
(5, 5, 5, 'Hanin', 'Hasan', 'E567890', '22E', 'Confirmed');

--
-- Triggers `ticket`
--
DROP TRIGGER IF EXISTS `upd_trigger`;
DELIMITER $$
CREATE TRIGGER `upd_trigger` BEFORE UPDATE ON `ticket` FOR EACH ROW BEGIN
IF NEW.TicketStatus = 'Cancelled' THEN
SET NEW.TicketStatus = 'Cancelled';
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `ticketfareview`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `ticketfareview`;
CREATE TABLE IF NOT EXISTS `ticketfareview` (
`TicketID` int
,`BookingID` int
,`FareID` int
,`PassengerFirstName` varchar(100)
,`PassengerLastName` varchar(100)
,`SeatNumber` varchar(10)
,`TicketStatus` enum('Confirmed','Cancelled')
,`ClassType` enum('Economy','Business','First')
,`Price` float
);

-- --------------------------------------------------------

--
-- Structure for view `fareflightdurationview`
--
DROP TABLE IF EXISTS `fareflightdurationview`;

DROP VIEW IF EXISTS `fareflightdurationview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `fareflightdurationview`  AS SELECT `fa`.`FareID` AS `FareID`, `fa`.`ClassType` AS `ClassType`, `fa`.`Price` AS `Price`, `fa`.`AvailableSeats` AS `AvailableSeats`, `f`.`FlightNumber` AS `FlightNumber`, `f`.`Duration` AS `Duration` FROM (`fare` `fa` join `flight` `f`) WHERE (`fa`.`FlightID` = `f`.`FlightID`) ;

-- --------------------------------------------------------

--
-- Structure for view `flightarrivalview`
--
DROP TABLE IF EXISTS `flightarrivalview`;

DROP VIEW IF EXISTS `flightarrivalview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `flightarrivalview`  AS SELECT `f`.`FlightID` AS `FlightID`, `f`.`FlightNumber` AS `FlightNumber`, `f`.`ArrAirportID` AS `ArrAirportID`, `a`.`Name` AS `ArrivalAirport`, `a`.`City` AS `ArrivalCity`, `a`.`Country` AS `ArrivalCountry` FROM (`flight` `f` join `airport` `a`) WHERE (`f`.`ArrAirportID` = `a`.`AirportID`) ;

-- --------------------------------------------------------

--
-- Structure for view `flightdepartureview`
--
DROP TABLE IF EXISTS `flightdepartureview`;

DROP VIEW IF EXISTS `flightdepartureview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `flightdepartureview`  AS SELECT `f`.`FlightID` AS `FlightID`, `f`.`FlightNumber` AS `FlightNumber`, `f`.`DepAirportID` AS `DepAirportID`, `a`.`Name` AS `DepartureAirport`, `a`.`City` AS `DepartureCity`, `a`.`Country` AS `DepartureCountry` FROM (`flight` `f` join `airport` `a`) WHERE (`f`.`DepAirportID` = `a`.`AirportID`) ;

-- --------------------------------------------------------

--
-- Structure for view `ticketfareview`
--
DROP TABLE IF EXISTS `ticketfareview`;

DROP VIEW IF EXISTS `ticketfareview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ticketfareview`  AS SELECT `t`.`TicketID` AS `TicketID`, `t`.`BookingID` AS `BookingID`, `t`.`FareID` AS `FareID`, `t`.`PassengerFirstName` AS `PassengerFirstName`, `t`.`PassengerLastName` AS `PassengerLastName`, `t`.`SeatNumber` AS `SeatNumber`, `t`.`TicketStatus` AS `TicketStatus`, `f`.`ClassType` AS `ClassType`, `f`.`Price` AS `Price` FROM (`ticket` `t` join `fare` `f`) WHERE (`t`.`FareID` = `f`.`FareID`) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

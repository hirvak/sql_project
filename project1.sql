-- ============================================================
-- 🏨 HOTEL MANAGEMENT DATABASE - COMPLETE SETUP SCRIPT
-- ============================================================
-- Author: Manushri
-- Description:
--     This script creates a normalized hotel management database,
--     loads raw data from a CSV into a staging table, 
--     and then populates the main relational tables.
-- ============================================================


-- ============================================================
-- 1️⃣  CREATE DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS hotel_management;
USE hotel_management;


-- ============================================================
-- 2️⃣  DROP EXISTING TABLES (RESET DATABASE)
-- ============================================================
-- Drop all tables in reverse dependency order to avoid FK errors
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Booking_Service;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Services;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Guest;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS staging_all_data;


-- ============================================================
-- 3️⃣  CREATE STAGING TABLE
-- ============================================================
-- The staging table stores data exactly as it appears in the CSV file.
-- It acts as a temporary raw data source before cleaning and normalization.
CREATE TABLE staging_all_data (
    -- User Information
    user_id BIGINT,
    username VARCHAR(100),
    password VARCHAR(255),
    role VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),

    -- Staff Information
    staff_id BIGINT,
    staff_user_id BIGINT,
    staff_name VARCHAR(100),
    staff_role VARCHAR(50),
    salary DECIMAL(10,2),
    shift VARCHAR(50),

    -- Guest Information
    guest_id BIGINT,
    guest_name VARCHAR(100),
    address VARCHAR(255),
    gender VARCHAR(10),
    id_proof VARCHAR(100),

    -- Room Information
    room_id BIGINT,
    room_no VARCHAR(10),
    room_type VARCHAR(50),
    price_per_night DECIMAL(10,2),
    room_status VARCHAR(50),

    -- Booking Information
    booking_id BIGINT,
    check_in DATE,
    check_out DATE,
    no_of_guests INT,
    booking_status VARCHAR(50),

    -- Payment Information
    payment_id BIGINT,
    amount DECIMAL(10,2),
    payment_date DATETIME,
    payment_mode VARCHAR(50),
    payment_status VARCHAR(50),

    -- Service Information
    service_id BIGINT,
    service_name VARCHAR(100),
    service_price DECIMAL(10,2),
    quantity INT,

    -- Review Information
    review_id BIGINT,
    rating INT,
    comments TEXT,
    review_date DATETIME
);


-- ============================================================
-- 4️⃣  ENABLE LOCAL FILE IMPORT
-- ============================================================
-- This allows MySQL to load local CSV files into tables.
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;


-- ============================================================
-- 5️⃣  LOAD CSV DATA INTO STAGING TABLE
-- ============================================================
-- Make sure the path and filename below match your system.
LOAD DATA LOCAL INFILE 'C:/Hirva/PDEU/Sem-3/RDBMS/PROJECT/hotel_management_dataset_final.csv'
INTO TABLE staging_all_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check if file loaded successfully
SHOW WARNINGS;
SELECT COUNT(*) AS Total_Records FROM staging_all_data;
SELECT * FROM staging_all_data LIMIT 10;


-- ============================================================
-- 6️⃣  CREATE MAIN NORMALIZED TABLES
-- ============================================================

-- ---------- USERS ----------
CREATE TABLE Users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    CHECK (role IN ('guest', 'staff', 'admin'))
);

-- ---------- STAFF ----------
CREATE TABLE Staff (
    staff_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    salary DECIMAL(10,2),
    shift VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ---------- GUEST ----------
CREATE TABLE Guest (
    guest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    gender VARCHAR(10),
    id_proof VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ---------- ROOMS ----------
CREATE TABLE Rooms (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_no VARCHAR(10) UNIQUE NOT NULL,
    room_type VARCHAR(50),
    price_per_night DECIMAL(10,2),
    status VARCHAR(50)
);

-- ---------- BOOKINGS ----------
CREATE TABLE Bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    check_in_date DATE,
    check_out_date DATE,
    no_of_guests INT,
    booking_status VARCHAR(50),
    staff_id BIGINT,
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- ---------- PAYMENTS ----------
CREATE TABLE Payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    amount DECIMAL(10,2),
    payment_date DATETIME,
    payment_mode VARCHAR(50),
    status VARCHAR(50),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- ---------- SERVICES ----------
CREATE TABLE Services (
    service_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100),
    service_price DECIMAL(10,2)
);

-- ---------- BOOKING-SERVICE LINK ----------
CREATE TABLE Booking_Service (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    quantity INT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- ---------- REVIEWS ----------
CREATE TABLE Review (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT,
    booking_id BIGINT,
    rating INT,
    comments TEXT,
    review_date DATETIME,
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);


-- ============================================================
-- 7️⃣  POPULATE MAIN TABLES FROM STAGING
-- ============================================================

-- ---- USERS ----
INSERT IGNORE INTO Users (username, password, role, email, phone)
SELECT DISTINCT username, password, role, email, phone
FROM staging_all_data
WHERE username IS NOT NULL
  AND role IN ('guest','staff','admin');
SELECT * FROM Users LIMIT 10;

-- ---- GUESTS ----
INSERT IGNORE INTO Guest (user_id, name, email, phone, address, gender, id_proof)
SELECT DISTINCT user_id, guest_name, email, phone, address, gender, id_proof
FROM staging_all_data
WHERE guest_name IS NOT NULL;
SELECT * FROM Guest LIMIT 10;

-- ---- ROOMS ----
INSERT IGNORE INTO Rooms (room_no, room_type, price_per_night, status)
SELECT DISTINCT room_no, room_type, price_per_night, room_status
FROM staging_all_data
WHERE room_no IS NOT NULL;
SELECT * FROM Rooms LIMIT 10;

-- ---- BOOKINGS ----
INSERT IGNORE INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status, staff_id)
SELECT DISTINCT guest_id, room_id, check_in, check_out, no_of_guests, booking_status, staff_id
FROM staging_all_data
WHERE booking_id IS NOT NULL;
SELECT * FROM Bookings LIMIT 10;

-- ---- BOOKING SERVICE ----
INSERT IGNORE INTO Booking_Service (booking_id, service_id, quantity)
SELECT DISTINCT booking_id, service_id, quantity
FROM staging_all_data
WHERE service_id IS NOT NULL;
SELECT * FROM Booking_Service LIMIT 10;

-- ---- PAYMENTS ----
INSERT IGNORE INTO Payment (booking_id, amount, payment_date, payment_mode, status)
SELECT DISTINCT booking_id, amount, payment_date, payment_mode, payment_status
FROM staging_all_data
WHERE payment_id IS NOT NULL;
SELECT * FROM Payment LIMIT 10;

-- ---- SERVICES ----
INSERT IGNORE INTO Services (service_name, service_price)
SELECT DISTINCT service_name, service_price
FROM staging_all_data
WHERE service_name IS NOT NULL;
SELECT * FROM Services LIMIT 10;

-- ---- STAFF ----
INSERT IGNORE INTO Staff (user_id, name, role, salary, shift)
SELECT DISTINCT user_id, staff_name, staff_role, salary, shift
FROM staging_all_data
WHERE staff_name IS NOT NULL;
SELECT * FROM Staff LIMIT 10;

-- ---- REVIEWS ----
INSERT IGNORE INTO Review (guest_id, booking_id, rating, comments, review_date)
SELECT DISTINCT guest_id, booking_id, rating, comments, review_date
FROM staging_all_data
WHERE rating IS NOT NULL;
SELECT * FROM Review LIMIT 10;



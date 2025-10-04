-- Create the hotel management database

CREATE DATABASE hotel_management;
USE hotel_management;

-- =========================
-- USERS TABLE
-- Stores all types of users: staff, guests, admins
-- =========================
CREATE TABLE Users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each user
    username VARCHAR(100) UNIQUE NOT NULL,      -- Unique username
    password VARCHAR(255) NOT NULL,             -- User password
    role VARCHAR(50) NOT NULL,                  -- Role: guest / staff / admin
    email VARCHAR(100) UNIQUE,                  -- Unique email
    phone VARCHAR(20),                          -- Contact number
    CHECK (role IN ('guest', 'staff', 'admin')) -- Constraint on valid roles
);

-- =========================
-- STAFF TABLE
-- Stores details of hotel staff (linked to Users)
-- =========================
CREATE TABLE Staff (
    staff_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique staff ID
    user_id BIGINT UNIQUE NOT NULL,             -- References user from Users table
    name VARCHAR(100) NOT NULL,                 -- Full name of staff
    role VARCHAR(50) NOT NULL,                  -- Staff role
    phone VARCHAR(20),                          -- Contact number
    salary DECIMAL(10, 2),                      -- Staff salary
    shift VARCHAR(50),                          -- Assigned shift
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CHECK (role IN ('manager', 'receptionist', 'housekeeping', 'chef'))
);

-- =========================
-- GUEST TABLE
-- Stores details of guests (linked to Users)
-- =========================
CREATE TABLE Guest (
    guest_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique guest ID
    user_id BIGINT UNIQUE NOT NULL,             -- References user from Users table
    name VARCHAR(100) NOT NULL,                 -- Guest full name
    email VARCHAR(100) UNIQUE NOT NULL,         -- Guest email
    phone VARCHAR(20),                          -- Contact number
    address VARCHAR(255),                       -- Address of guest
    gender VARCHAR(10),                         -- Gender
    id_proof VARCHAR(100) UNIQUE,               -- ID proof (e.g., passport, Aadhaar)
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- =========================
-- ROOMS TABLE
-- Stores details of rooms in the hotel
-- =========================
CREATE TABLE Rooms (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,     -- Unique room ID
    room_no VARCHAR(10) UNIQUE NOT NULL,           -- Room number
    room_type VARCHAR(50) NOT NULL,                -- Type: Single, Double, Suite, Deluxe
    price_per_night DECIMAL(10, 2) NOT NULL,       -- Price per night
    status VARCHAR(50) NOT NULL,                   -- Availability status
    CHECK (room_type IN ('Single', 'Double', 'Suite', 'Deluxe')),
    CHECK (status IN ('Available', 'Occupied', 'Maintenance'))
);

-- =========================
-- BOOKINGS TABLE
-- Stores booking details (guest-room relationship)
-- =========================
CREATE TABLE Bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique booking ID
    guest_id BIGINT NOT NULL,                     -- References Guest
    room_id BIGINT NOT NULL,                      -- References Room
    check_in_date DATE NOT NULL,                  -- Check-in date
    check_out_date DATE NOT NULL,                 -- Check-out date
    no_of_guests INT NOT NULL,                    -- Number of guests
    booking_status VARCHAR(50) NOT NULL,          -- Status of booking
    staff_id BIGINT,                              -- Staff who handled booking
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    CHECK (check_out_date > check_in_date),       -- Ensure valid dates
    CHECK (booking_status IN ('Confirmed', 'Cancelled', 'Checked-In', 'Checked-Out'))
);



-- =========================
-- PAYMENT TABLE
-- Stores payments made for bookings
-- =========================
DROP TABLE IF EXISTS Payment;

CREATE TABLE Payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATETIME NOT NULL,
    payment_mode ENUM('Credit Card', 'Cash', 'Online Transfer') NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed') NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);



-- =========================
-- SERVICES TABLE
-- Stores hotel services (laundry, spa, etc.)
-- =========================
CREATE TABLE Services (
    service_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique service ID
    service_name VARCHAR(100) UNIQUE NOT NULL,    -- Service name
    service_price DECIMAL(10, 2) NOT NULL         -- Price of service
);

-- =========================
-- BOOKING_SERVICE TABLE
-- Junction table for booking-service relationship
-- =========================
CREATE TABLE Booking_Service (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL, -- References booking
    service_id BIGINT NOT NULL, -- References service
    quantity INT NOT NULL DEFAULT 1, -- Quantity (e.g., 2 spa treatments)
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id),
    UNIQUE (booking_id, service_id) -- Prevents duplicate service entries for same booking
);

-- =========================
-- REVIEW TABLE
-- Stores guest reviews for bookings
-- =========================
CREATE TABLE Review (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY, -- Unique review ID
    guest_id BIGINT NOT NULL,                    -- Guest who left review
    booking_id BIGINT NOT NULL,           -- One review per booking
    rating INT NOT NULL,                         -- Rating (1–5)
    comments TEXT,                               -- Optional comments
    review_date DATETIME NOT NULL,               -- Date of review
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CHECK (rating BETWEEN 1 AND 5)
);

-- =========================
-- INSERT SAMPLE DATA
-- =========================

-- =========================
-- INSERT SAMPLE DATA (FIXED)
-- =========================

-- Insert staff & guest user accounts into Users table
INSERT INTO Users (username, password, role, email, phone) VALUES
-- Staff Users
('charlie_user', 'staffpass1', 'staff', 'charlie.user@hotel.com', '222-333-5555'),
('david_user', 'staffpass2', 'staff', 'david.user@hotel.com', '222-333-6666'),
('grace_user', 'staffpass3', 'staff', 'grace.user@hotel.com', '222-333-9999'),
('kelly_user', 'staffpass4', 'staff', 'kelly.user@hotel.com', '222-333-2222'),
('ella_user', 'staffpass5', 'staff', 'ella.user@hotel.com', '555-111-2222'),
('fiona_user', 'staffpass6', 'staff', 'fiona.user@hotel.com', '555-111-3333'),
('george_user', 'staffpass7', 'staff', 'george.user@hotel.com', '555-111-4444'),
('hannah_user', 'staffpass8', 'staff', 'hannah.user@hotel.com', '555-111-5555'),
('igor_user', 'staffpass9', 'staff', 'igor.user@hotel.com', '555-111-6666'),
('janet_user', 'staffpass10', 'staff', 'janet.user@hotel.com', '555-111-7777'),
-- Guest Users
('alice_guest', 'gpass01', 'guest', 'alice.guest@mail.com', '111-111-1111'),
('bob_guest', 'gpass02', 'guest', 'bob.guest@mail.com', '111-111-2222'),
('eve_guest', 'gpass03', 'guest', 'eve.guest@mail.com', '111-111-3333'),
('frank_guest', 'gpass04', 'guest', 'frank.guest@mail.com', '111-111-4444'),
('helen_guest', 'gpass05', 'guest', 'helen.guest@mail.com', '111-111-5555'),
('ivan_guest', 'gpass06', 'guest', 'ivan.guest@mail.com', '111-111-6666'),
('julia_guest', 'gpass07', 'guest', 'julia.guest@mail.com', '111-111-7777'),
('ken_guest', 'gpass08', 'guest', 'ken.guest@mail.com', '111-111-8888'),
('lana_guest', 'gpass09', 'guest', 'lana.guest@mail.com', '111-111-9999'),
('mike_guest', 'gpass10', 'guest', 'mike.guest@mail.com', '111-111-0000');

-- Insert staff details
INSERT INTO Staff (user_id, name, role, phone, salary, shift) VALUES
(1, 'Charlie Green', 'receptionist', '222-333-5555', 35000.00, 'Day'),
(2, 'David Blue', 'housekeeping', '222-333-6666', 30000.00, 'Morning'),
(3, 'Grace Yellow', 'manager', '222-333-9999', 60000.00, 'Day'),
(4, 'Kelly White', 'chef', '222-333-2222', 45000.00, 'Evening'),
(5, 'Ella Black', 'receptionist', '555-111-2222', 34000.00, 'Night'),
(6, 'Fiona Red', 'housekeeping', '555-111-3333', 29000.00, 'Morning'),
(7, 'George Brown', 'chef', '555-111-4444', 48000.00, 'Day'),
(8, 'Hannah Grey', 'manager', '555-111-5555', 62000.00, 'Night'),
(9, 'Igor Petrov', 'receptionist', '555-111-6666', 36000.00, 'Day'),
(10, 'Janet Singh', 'housekeeping', '555-111-7777', 31000.00, 'Evening');

-- Insert guest details
INSERT INTO Guest (user_id, name, email, phone, address, gender, id_proof) VALUES
(11, 'Alice Smith', 'alice.guest@mail.com', '111-111-1111', '123 Main St, City A', 'Female', 'ID_A456'),
(12, 'Bob Johnson', 'bob.guest@mail.com', '111-111-2222', '456 Oak Ave, City B', 'Male', 'ID_C789'),
(13, 'Eve Davis', 'eve.guest@mail.com', '111-111-3333', '789 Pine Ln, City C', 'Female', 'ID_E123'),
(14, 'Frank White', 'frank.guest@mail.com', '111-111-4444', '101 Elm Blvd, City D', 'Male', 'ID_G456'),
(15, 'Helen Brown', 'helen.guest@mail.com', '111-111-5555', '202 Birch Rd, City E', 'Female', 'ID_I789'),
(16, 'Ivan Lee', 'ivan.guest@mail.com', '111-111-6666', '303 Cedar Dr, City F', 'Male', 'ID_K123'),
(17, 'Julia Chen', 'julia.guest@mail.com', '111-111-7777', '404 Maple Ct, City G', 'Female', 'ID_M456'),
(18, 'Ken Miller', 'ken.guest@mail.com', '111-111-8888', '505 Aspen Way, City H', 'Male', 'ID_O789'),
(19, 'Lana Petrova', 'lana.guest@mail.com', '111-111-9999', '606 Willow Ter, City I', 'Female', 'ID_Q123'),
(20, 'Mike Ross', 'mike.guest@mail.com', '111-111-0000', '707 Poplar Pk, City J', 'Male', 'ID_S456');


-- Insert rooms
INSERT INTO Rooms (room_no, room_type, price_per_night, status) VALUES
('101', 'Single', 80.00, 'Occupied'),
('102', 'Double', 120.00, 'Available'),
('201', 'Suite', 250.00, 'Available'),
('202', 'Double', 120.00, 'Occupied'),
('301', 'Deluxe', 180.00, 'Available'),
('302', 'Single', 80.00, 'Occupied'),
('401', 'Suite', 250.00, 'Maintenance'),
('402', 'Double', 120.00, 'Available'),
('501', 'Deluxe', 180.00, 'Available'),
('502', 'Single', 80.00, 'Available');

-- Insert bookings
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status, staff_id) VALUES
(1, 1, '2025-10-10', '2025-10-12', 2, 'Confirmed', 1),
(1, 2, '2025-10-10', '2025-10-12', 1, 'Confirmed', 1),
(2, 3, '2025-10-05', '2025-10-07', 1, 'Checked-In', 2),
(2, 2, '2025-10-15', '2025-10-17', 2, 'Checked-Out', 2),
(2, 4, '2025-10-20', '2025-10-22', 1, 'Cancelled', 2),
(3, 3, '2025-10-08', '2025-10-11', 2, 'Confirmed', 3),
(4, 3, '2025-10-10', '2025-10-12', 1, 'Confirmed', 3),
(4, 1, '2025-10-01', '2025-10-03', 1, 'Checked-In', 1),
(4, 1, '2025-10-20', '2025-10-22', 2, 'Checked-Out', 1),
(5, 2, '2025-10-25', '2025-10-28', 1, 'Confirmed', NULL);

-- ✅ Fixed payments (booking_id now matches 1–10)
INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status)
VALUES 
(1, 250.00, '2025-10-01 14:30:00', 'Credit Card', 'Completed'),
(2, 500.00, '2025-10-02 09:15:00', 'Cash', 'Pending'),
(3, 1200.50, '2025-10-02 18:45:00', 'Online Transfer', 'Completed'),
(4, 300.00, '2025-10-03 10:20:00', 'Credit Card', 'Failed'),
(5, 750.75, '2025-10-03 16:55:00', 'Cash', 'Completed');

-- Insert services
INSERT INTO Services (service_name, service_price) VALUES
('Laundry', 15.00),
('Room Service Dinner', 45.00),
('Extra Towels', 5.00),
('Minibar Restock', 30.00),
('Spa Treatment', 80.00),
('Airport Shuttle', 25.00),
('Pet Sitting', 50.00),
('Bike Rental (Day)', 20.00),
('Late Check-Out', 50.00),
('Concierge Assistance', 0.00);

-- Insert booking services
INSERT INTO Booking_Service (booking_id, service_id, quantity) VALUES
(1, 1, 3),
(1, 2, 1),
(2, 3, 2),
(3, 4, 1),
(4, 5, 1),
(5, 6, 1),
(6, 7, 1),
(7, 8, 2),
(8, 9, 1),
(9, 10, 1);
INSERT INTO Booking_Service (booking_id, service_id, quantity) VALUES
(10, 1, 2);
-- Insert guest reviews
INSERT INTO Review (guest_id, booking_id, rating, comments, review_date) VALUES
(1, 1, 5, 'The stay was excellent, service was top-notch.', '2025-10-05 10:00:00'),
(2, 2, 4, 'Very comfortable room, slightly noisy location.', '2025-10-18 11:30:00'),
(3, 3, 5, 'Fantastic experience, great value for money.', '2025-10-03 15:00:00'),
(4, 4, 3, 'Room was fine, but check-in process was slow.', '2025-10-22 12:00:00'),
(5, 5, 4, 'Loved the Deluxe room. The staff was attentive.', '2025-10-04 10:00:00'),
(6, 6, 5, 'Seamless check-out. Would definitely book again.', '2025-09-30 11:00:00'),
(7, 7, 4, 'Great view and spacious room for four guests.', '2025-10-30 09:30:00'),
(8, 8, 2, 'The minibar was not fully stocked upon arrival.', '2025-10-06 13:00:00'),
(9, 9, 5, 'Highly recommend this hotel!', '2025-10-10 12:30:00'),
(10, 10, 1, 'Extremely disappointed with the cancellation fee.', '2025-09-12 09:00:00');


select * from Users;
select * from Guest;
select * from payment;
select * from Bookings;
select * from Rooms;
select * from Staff;
select * from Review;
select * from Services;
select * from Booking_Service;


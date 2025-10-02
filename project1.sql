
create database hotel_management;
use hotel_management;

CREATE TABLE Users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    CHECK (role IN ('guest', 'staff', 'admin'))
);

CREATE TABLE Staff (
    staff_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    salary DECIMAL(10, 2),
    shift VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CHECK (role IN ('manager', 'receptionist', 'housekeeping', 'chef'))
);

CREATE TABLE Guest (
    guest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    gender VARCHAR(10),
    id_proof VARCHAR(100) UNIQUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Rooms (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_no VARCHAR(10) UNIQUE NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    CHECK (room_type IN ('Single', 'Double', 'Suite', 'Deluxe')),
    CHECK (status IN ('Available', 'Occupied', 'Maintenance'))
);

CREATE TABLE Bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    no_of_guests INT NOT NULL,
    booking_status VARCHAR(50) NOT NULL,
    staff_id BIGINT, -- This column has been added via ALTER
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id), -- This constraint has been added via ALTER
    CHECK (check_out_date > check_in_date),
    CHECK (booking_status IN ('Confirmed', 'Cancelled', 'Checked-In', 'Checked-Out'))
);

CREATE TABLE Payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL,
    payment_mode VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CHECK (payment_mode IN ('Credit Card', 'Cash', 'Online Transfer')),
    CHECK (status IN ('Pending', 'Completed', 'Failed'))
);

CREATE TABLE Services (
    service_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) UNIQUE NOT NULL,
    service_price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Booking_Service (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id),
    UNIQUE (booking_id, service_id) -- Ensures a service isn't listed twice for the same booking
);

CREATE TABLE Review (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT NOT NULL,
    booking_id BIGINT UNIQUE NOT NULL, -- Assuming 1 review per booking (1 to 1)
    rating INT NOT NULL,
    comments TEXT,
    review_date DATETIME NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CHECK (rating BETWEEN 1 AND 5)
);

INSERT INTO Users (username, password, role, email, phone) VALUES
-- Staff Users (user_id 1 - 10)
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
-- Guest Users (user_id 11 - 20)
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

INSERT INTO Staff (user_id, name, role, phone, salary, shift) VALUES
(1, 'Charlie Green', 'receptionist', '222-333-5555', 35000.00, 'Day'),   -- staff_id 1
(2, 'David Blue', 'housekeeping', '222-333-6666', 30000.00, 'Morning'),  -- staff_id 2
(3, 'Grace Yellow', 'manager', '222-333-9999', 60000.00, 'Day'),         -- staff_id 3
(4, 'Kelly White', 'chef', '222-333-2222', 45000.00, 'Evening'),        -- staff_id 4
(5, 'Ella Black', 'receptionist', '555-111-2222', 34000.00, 'Night'),    -- staff_id 5
(6, 'Fiona Red', 'housekeeping', '555-111-3333', 29000.00, 'Morning'),   -- staff_id 6
(7, 'George Brown', 'chef', '555-111-4444', 48000.00, 'Day'),            -- staff_id 7
(8, 'Hannah Grey', 'manager', '555-111-5555', 62000.00, 'Night'),        -- staff_id 8
(9, 'Igor Petrov', 'receptionist', '555-111-6666', 36000.00, 'Day'),     -- staff_id 9
(10, 'Janet Singh', 'housekeeping', '555-111-7777', 31000.00, 'Evening'); -- staff_id 10

INSERT INTO Guest (user_id, name, email, phone, address, gender, id_proof) VALUES
(11, 'Alice Smith', 'alice.guest@mail.com', '111-111-1111', '123 Main St, City A', 'Female', 'ID_A456'),   -- guest_id 1
(12, 'Bob Johnson', 'bob.guest@mail.com', '111-111-2222', '456 Oak Ave, City B', 'Male', 'ID_C789'),      -- guest_id 2
(13, 'Eve Davis', 'eve.guest@mail.com', '111-111-3333', '789 Pine Ln, City C', 'Female', 'ID_E123'),      -- guest_id 3
(14, 'Frank White', 'frank.guest@mail.com', '111-111-4444', '101 Elm Blvd, City D', 'Male', 'ID_G456'),   -- guest_id 4
(15, 'Helen Brown', 'helen.guest@mail.com', '111-111-5555', '202 Birch Rd, City E', 'Female', 'ID_I789'), -- guest_id 5
(16, 'Ivan Lee', 'ivan.guest@mail.com', '111-111-6666', '303 Cedar Dr, City F', 'Male', 'ID_K123'),       -- guest_id 6
(17, 'Julia Chen', 'julia.guest@mail.com', '111-111-7777', '404 Maple Ct, City G', 'Female', 'ID_M456'),   -- guest_id 7
(18, 'Ken Miller', 'ken.guest@mail.com', '111-111-8888', '505 Aspen Way, City H', 'Male', 'ID_O789'),     -- guest_id 8
(19, 'Lana Petrova', 'lana.guest@mail.com', '111-111-9999', '606 Willow Ter, City I', 'Female', 'ID_Q123'),-- guest_id 9
(20, 'Mike Ross', 'mike.guest@mail.com', '111-111-0000', '707 Poplar Pk, City J', 'Male', 'ID_S456');     -- guest_id 10

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

INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status, staff_id) VALUES
(1, 1, '2025-10-01', '2025-10-05', 2, 'Checked-In', 1),   -- staff_id 1: Charlie Green (Receptionist)
(2, 2, '2025-10-15', '2025-10-18', 1, 'Confirmed', 5),    -- staff_id 5: Ella Black (Receptionist)
(3, 4, '2025-09-28', '2025-10-03', 2, 'Checked-Out', 2),  -- staff_id 2: David Blue (Housekeeping)
(4, 3, '2025-10-20', '2025-10-22', 3, 'Confirmed', 8),    -- staff_id 8: Hannah Grey (Manager)
(5, 5, '2025-10-02', '2025-10-04', 1, 'Checked-In', 9),   -- staff_id 9: Igor Petrov (Receptionist)
(6, 6, '2025-09-25', '2025-09-30', 2, 'Checked-Out', 6),  -- staff_id 6: Fiona Red (Housekeeping)
(7, 8, '2025-10-25', '2025-10-30', 4, 'Confirmed', 3),    -- staff_id 3: Grace Yellow (Manager)
(8, 9, '2025-10-03', '2025-10-06', 1, 'Confirmed', 5),
(9, 10, '2025-10-07', '2025-10-10', 2, 'Confirmed', 1),
(10, 2, '2025-09-10', '2025-09-12', 1, 'Cancelled', 8);

INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status) VALUES
(1, 480.00, '2025-09-20 14:30:00', 'Credit Card', 'Completed'),
(2, 360.00, '2025-10-10 10:00:00', 'Online Transfer', 'Pending'),
(3, 600.00, '2025-09-28 11:15:00', 'Cash', 'Completed'),
(4, 500.00, '2025-10-15 09:00:00', 'Credit Card', 'Completed'),
(5, 360.00, '2025-10-01 16:45:00', 'Cash', 'Completed'),
(6, 400.00, '2025-09-15 12:00:00', 'Online Transfer', 'Completed'),
(7, 600.00, '2025-10-20 08:30:00', 'Credit Card', 'Pending'),
(8, 540.00, '2025-10-02 14:00:00', 'Online Transfer', 'Completed'),
(9, 240.00, '2025-10-06 17:00:00', 'Credit Card', 'Pending'),
(10, 240.00, '2025-09-01 10:00:00', 'Cash', 'Failed');

INSERT INTO Services (service_name, service_price) VALUES
('Laundry', 15.00),         -- service_id 1
('Room Service Dinner', 45.00), -- service_id 2
('Extra Towels', 5.00),     -- service_id 3
('Minibar Restock', 30.00), -- service_id 4
('Spa Treatment', 80.00),   -- service_id 5
('Airport Shuttle', 25.00), -- service_id 6
('Pet Sitting', 50.00),     -- service_id 7
('Bike Rental (Day)', 20.00),-- service_id 8
('Late Check-Out', 50.00),  -- service_id 9
('Concierge Assistance', 0.00);-- service_id 10

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

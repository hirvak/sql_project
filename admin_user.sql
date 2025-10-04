-- ==========================================================
-- ADMIN ACCESS SCRIPT
-- Database: hotel_management
-- Description:
--   Admin has full control over the database.
--   Can create and manage views, triggers, and procedures.
--   Handles all CRUD operations, reporting, and automation.
-- ==========================================================

USE hotel_management;

-- Clean existing sample data (optional for testing)
DELETE FROM Payment WHERE payment_id = 1;
SELECT * FROM Payment;


-- ==========================================================
-- VIEW: Guest_Bookings
-- Purpose:
--   Displays combined booking, payment, and review information 
--   for each guest in a single summarized view.
-- ==========================================================

CREATE OR REPLACE VIEW Guest_Bookings AS
SELECT 
    B.booking_id,
    R.room_no,
    R.room_type,
    B.check_in_date,
    B.check_out_date,
    B.no_of_guests,
    B.booking_status,
    G.user_id,
    COALESCE(P.amount, 0) AS payment_amount,  -- Handles nulls (no payment yet)
    COALESCE(P.status, 'Not Paid') AS payment_status,
    Rev.comments AS review_comments,
    Rev.rating AS review_rating
FROM Bookings B
JOIN Guest G ON B.guest_id = G.guest_id
JOIN Rooms R ON B.room_id = R.room_id
LEFT JOIN Payment P ON B.booking_id = P.booking_id
LEFT JOIN Review Rev ON B.booking_id = Rev.booking_id;


-- ==========================================================
-- TRIGGER 1: after_booking_insert
-- Purpose:
--   Automatically marks a room as 'Occupied' 
--   when a new booking is created.
-- ==========================================================
DELIMITER $$

CREATE TRIGGER after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = NEW.room_id;
END$$

DELIMITER ;

-- Test the trigger
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status)
VALUES (1, 3, '2025-10-05', '2025-10-07', 2, 'Confirmed');

-- Verify if the room status updated to 'Occupied'
SELECT room_id, status FROM Rooms WHERE room_id = 3;


-- ==========================================================
-- TRIGGER 2: after_booking_update
-- Purpose:
--   Automatically marks a room as 'Available'
--   when the booking is 'Cancelled' or 'CheckedOut'.
-- ==========================================================
DELIMITER $$

CREATE TRIGGER after_booking_update
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status IN ('Cancelled', 'CheckedOut') THEN
        UPDATE Rooms
        SET status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;
END$$

DELIMITER ;

-- Test the trigger by cancelling a booking
UPDATE Bookings
SET booking_status = 'Cancelled'
WHERE booking_id = 3;

-- Verify that the room is now marked as 'Available'
SELECT room_id, status FROM Rooms WHERE room_id = 3;


-- ==========================================================
-- PROCEDURE 1: AddBooking
-- Purpose:
--   Adds a booking and automatically sets the room as 'Occupied'.
-- ==========================================================
DELIMITER $$

CREATE PROCEDURE AddBooking (
    IN p_guest_id BIGINT,
    IN p_room_id BIGINT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_no_of_guests INT
)
BEGIN
    INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, p_no_of_guests, 'Confirmed');

    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = p_room_id;
END$$

DELIMITER ;

-- Test the AddBooking procedure
CALL AddBooking(1, 2, '2025-10-10', '2025-10-12', 2);
SELECT * FROM Bookings WHERE guest_id = 1;
SELECT room_id, status FROM Rooms WHERE room_id = 2;


-- ==========================================================
-- PROCEDURE 2: MakePayment
-- Purpose:
--   Adds a payment record and marks the booking as 'Paid'
--   (only if the booking is not cancelled).
-- ==========================================================

-- Ensure the CHECK constraint allows 'Paid'
ALTER TABLE Bookings
DROP CHECK IF EXISTS bookings_chk_2,
ADD CONSTRAINT bookings_chk_2
CHECK (booking_status IN ('Confirmed', 'Cancelled', 'Checked-In', 'Checked-Out', 'Paid'));

DELIMITER $$

CREATE PROCEDURE MakePayment (
    IN p_booking_id BIGINT,
    IN p_amount DECIMAL(10,2),
    IN p_mode VARCHAR(50)
)
BEGIN
    INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status)
    VALUES (p_booking_id, p_amount, NOW(), p_mode, 'Completed');

    UPDATE Bookings
    SET booking_status = 'Paid'
    WHERE booking_id = p_booking_id
      AND booking_status <> 'Cancelled';
END$$

DELIMITER ;

-- Test the MakePayment procedure
CALL MakePayment(3, 450.00, 'Cash');
SELECT * FROM Payment WHERE booking_id = 3;
SELECT booking_id, booking_status FROM Bookings WHERE booking_id = 3;


-- ==========================================================
-- PROCEDURE 3: GetGuestBookings
-- Purpose:
--   Displays all bookings and corresponding payment information
--   for a specific guest.
-- ==========================================================
DELIMITER $$

CREATE PROCEDURE GetGuestBookings (
    IN p_guest_id BIGINT
)
BEGIN
    SELECT 
        B.booking_id,
        R.room_no,
        B.check_in_date,
        B.check_out_date,
        B.booking_status,
        COALESCE(P.amount, 0) AS payment_amount,
        COALESCE(P.status, 'Not Paid') AS payment_status
    FROM Bookings B
    JOIN Rooms R ON B.room_id = R.room_id
    LEFT JOIN Payment P ON B.booking_id = P.booking_id
    WHERE B.guest_id = p_guest_id;
END$$

DELIMITER ;

-- Test the GetGuestBookings procedure
CALL GetGuestBookings(1);

SHOW PROCEDURE STATUS WHERE Db = 'hotel_management';


-- ==========================================================
-- SUMMARY AND VERIFICATION
-- ==========================================================
SHOW GRANTS FOR CURRENT_USER();
SHOW TRIGGERS FROM hotel_management;

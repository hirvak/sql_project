-- ==========================================================
-- HOTEL MANAGEMENT SYSTEM: TRIGGERS & STORED PROCEDURES
-- Purpose: Automate booking, payment, and room management
-- Database: hotel_management
-- ==========================================================

USE hotel_management;

-- ==========================================================
-- TRIGGER 1: Update Room Status After Booking Insert
-- Purpose:
--   Automatically marks a room as 'Occupied' when a new booking is created.
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

-- ✅ Test Trigger 1
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status)
VALUES (1, 3, '2025-10-10', '2025-10-12', 2, 'Confirmed');

SELECT room_id, status FROM Rooms WHERE room_id = 3;


-- ==========================================================
-- TRIGGER 2: Refund Payment After Booking Cancel
-- Purpose:
--   Automatically refunds payment and marks room as 'Available' when booking is cancelled.
-- ==========================================================
DROP TRIGGER IF EXISTS after_booking_cancel;
DELIMITER $$
CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'Cancelled' THEN
        UPDATE Payment
        SET status = 'Refunded'
        WHERE booking_id = NEW.booking_id;

        UPDATE Rooms
        SET status = 'Available'
        WHERE room_id = NEW.room_id;
    END IF;
END$$
DELIMITER ;

-- Ensure Payment status column supports all required values
ALTER TABLE Payment 
MODIFY COLUMN status ENUM('Pending','Completed','Failed','Refunded') DEFAULT 'Pending';

-- ✅ Test Trigger 2
UPDATE Bookings
SET booking_status = 'Cancelled'
WHERE booking_id = 3;

SELECT booking_id, booking_status FROM Bookings WHERE booking_id = 3;
SELECT room_id, status FROM Rooms WHERE room_id = (SELECT room_id FROM Bookings WHERE booking_id = 3);
SELECT booking_id, status FROM Payment WHERE booking_id = 3;


-- ==========================================================
-- TRIGGER 3: Insert Default Service Charge
-- Purpose:
--   Automatically adds a pending payment entry whenever a new service is booked.
-- ==========================================================
DROP TRIGGER IF EXISTS after_service_insert;
DELIMITER $$
CREATE TRIGGER after_service_insert
AFTER INSERT ON Booking_Service
FOR EACH ROW
BEGIN
    INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status)
    VALUES (NEW.booking_id, 50.00 * NEW.quantity, NOW(), 'Cash', 'Pending');
END$$
DELIMITER ;

-- ✅ Test Trigger 3
INSERT INTO Booking_Service (booking_id, service_id, quantity)
VALUES (4, 2, 1);

SELECT * FROM Payment WHERE booking_id = 4 ORDER BY payment_id DESC LIMIT 1;


-- ==========================================================
-- PROCEDURE 1: make_booking
-- Purpose:
--   Creates a booking, generates a payment, and updates room status (transaction-safe).
-- ==========================================================
DELIMITER $$
CREATE PROCEDURE make_booking(
    IN p_guest_id BIGINT,
    IN p_room_id BIGINT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_no_of_guests INT,
    IN p_amount DECIMAL(10,2),
    IN p_payment_mode VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ Error! Transaction Rolled Back' AS message;
    END;

    START TRANSACTION;

    INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, no_of_guests, booking_status)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, p_no_of_guests, 'Confirmed');

    INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status)
    VALUES (LAST_INSERT_ID(), p_amount, NOW(), p_payment_mode, 'Completed');

    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = p_room_id;

    COMMIT;
    SELECT '✅ Booking Successful' AS message;
END$$
DELIMITER ;

-- ✅ Test Procedure 1
CALL make_booking(1, 4, '2025-10-15', '2025-10-18', 2, 5000.00, 'Credit Card');
SELECT * FROM Bookings ORDER BY booking_id DESC;
SELECT * FROM Payment ORDER BY payment_id DESC;
SELECT * FROM Rooms WHERE room_id = 4;


-- ==========================================================
-- PROCEDURE 2: cancel_booking
-- Purpose:
--   Cancels booking, refunds payment, and marks the room available.
-- ==========================================================
DELIMITER $$
CREATE PROCEDURE cancel_booking(IN p_booking_id BIGINT)
BEGIN
    DECLARE v_room_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ Cancellation Failed. Rolled Back' AS message;
    END;

    START TRANSACTION;

    SELECT room_id INTO v_room_id FROM Bookings WHERE booking_id = p_booking_id;

    UPDATE Bookings SET booking_status = 'Cancelled' WHERE booking_id = p_booking_id;
    UPDATE Payment SET status = 'Refunded' WHERE booking_id = p_booking_id;
    UPDATE Rooms SET status = 'Available' WHERE room_id = v_room_id;

    COMMIT;
    SELECT '✅ Booking Cancelled and Payment Refunded' AS message;
END$$
DELIMITER ;

-- ✅ Test Procedure 2
CALL cancel_booking(4);
SELECT * FROM Bookings WHERE booking_id = 4;
SELECT * FROM Payment WHERE booking_id = 4;
SELECT * FROM Rooms WHERE room_id = (SELECT room_id FROM Bookings WHERE booking_id = 4);


-- ==========================================================
-- PROCEDURE 3: check_in
-- Purpose:
--   Updates booking status to 'Checked-In' for guest arrival.
-- ==========================================================
DELIMITER $$
CREATE PROCEDURE check_in(IN p_booking_id BIGINT)
BEGIN
    UPDATE Bookings
    SET booking_status = 'Checked-In'
    WHERE booking_id = p_booking_id;

    SELECT '✅ Guest Checked-In Successfully' AS message;
END$$
DELIMITER ;

-- ✅ Test Procedure 3
CALL check_in(5);
SELECT booking_id, booking_status FROM Bookings WHERE booking_id = 5;


-- ==========================================================
-- PROCEDURE 4: check_out
-- Purpose:
--   Marks guest as checked-out and sets room to 'Available'.
-- ==========================================================
DELIMITER $$
CREATE PROCEDURE check_out(IN p_booking_id BIGINT)
BEGIN
    DECLARE v_room_id BIGINT;

    SELECT room_id INTO v_room_id FROM Bookings WHERE booking_id = p_booking_id;

    UPDATE Bookings
    SET booking_status = 'Checked-Out'
    WHERE booking_id = p_booking_id;

    UPDATE Rooms
    SET status = 'Available'
    WHERE room_id = v_room_id;

    SELECT '✅ Guest Checked-Out and Room Marked Available' AS message;
END$$
DELIMITER ;

-- ✅ Test Procedure 4
CALL check_out(5);
SELECT booking_id, booking_status FROM Bookings WHERE booking_id = 5;
SELECT room_id, status FROM Rooms WHERE room_id = (SELECT room_id FROM Bookings WHERE booking_id = 5);


-- ==========================================================
-- PROCEDURE 5: add_service
-- Purpose:
--   Adds a service for a booking and generates pending payment.
-- ==========================================================
DELIMITER $$
CREATE PROCEDURE add_service(
    IN p_booking_id BIGINT,
    IN p_service_id BIGINT,
    IN p_quantity INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ Error Adding Service. Rolled Back' AS message;
    END;

    START TRANSACTION;

    INSERT INTO Booking_Service (booking_id, service_id, quantity)
    VALUES (p_booking_id, p_service_id, p_quantity);

    INSERT INTO Payment (booking_id, amount, payment_date, payment_mode, status)
    VALUES (p_booking_id, 50.00 * p_quantity, NOW(), 'Cash', 'Pending');

    COMMIT;
    SELECT '✅ Service Added and Payment Recorded' AS message;
END$$
DELIMITER ;

-- ✅ Test Procedure 5
CALL add_service(3, 1, 2);
SELECT * FROM Booking_Service WHERE booking_id = 3;
SELECT * FROM Payment WHERE booking_id = 3 ORDER BY payment_id DESC;


-- ==========================================================
-- PROCEDURE 6: MakePayment
-- Purpose:
--   Adds payment record and updates booking status to 'Paid' (if not cancelled).
-- ==========================================================
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

-- ✅ Test Procedure 6
CALL MakePayment(3, 450.00, 'Cash');
SELECT * FROM Payment WHERE booking_id = 3;
SELECT booking_id, booking_status FROM Bookings WHERE booking_id = 3;


-- ==========================================================
-- PROCEDURE 7: GetGuestBookings
-- Purpose:
--   Displays all bookings and related payment info for a given guest.
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

-- ✅ Test Procedure 7
CALL GetGuestBookings(1);


-- ==========================================================
-- VERIFICATION COMMANDS
-- ==========================================================
SHOW TRIGGERS FROM hotel_management;
SHOW PROCEDURE STATUS WHERE Db = 'hotel_management';

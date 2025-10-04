-- ==========================================================
-- STAFF USER ACCESS (Operational Privileges)
-- ==========================================================
-- This section defines what a staff-level user can and cannot do.
-- Staff members handle operational tasks such as managing rooms,
-- updating booking statuses, and recording payments.
--
-- They can:
--   - View and update Rooms and Bookings
--   - View Guest information (for operational reference)
--   - Record new Payments for guests
-- They cannot:
--   - Delete core data (Bookings, Guests, Rooms)
--   - Alter database structure (DROP, ALTER)
-- ==========================================================

USE hotel_management;

-- Disable safe update mode (required for certain UPDATE operations)
SELECT @@sql_safe_updates;
SET SQL_SAFE_UPDATES = 0;

-- ==========================================================
-- ROOM MANAGEMENT
-- ==========================================================
-- Staff can view all rooms to check availability and current status
SELECT * FROM Rooms;

-- Staff can update room status (for example, mark a room as Available after cleaning)
UPDATE Rooms
SET status = 'Available'
WHERE room_no = 101;

-- ==========================================================
-- BOOKING MANAGEMENT
-- ==========================================================
-- Staff can view all bookings to assist guests
SELECT * FROM Bookings;

-- Staff can update booking status (for example, mark a booking as Checked-Out)
UPDATE Bookings
SET booking_status = 'Checked-Out'
WHERE booking_id = 3;

-- ==========================================================
-- GUEST INFORMATION ACCESS
-- ==========================================================
-- Staff can view guest details for check-in/check-out purposes
-- Staff cannot modify guest records
SELECT * FROM Guest;

-- ==========================================================
-- RESTRICTED OPERATIONS (Should Fail for Staff User)
-- ==========================================================
-- Staff cannot delete booking records
DELETE FROM Bookings WHERE booking_id = 1;

-- Staff cannot modify database structure
DROP TABLE Rooms;

-- Staff cannot insert new rooms (this is an admin-level task)
INSERT INTO Rooms (room_no, room_type, price_per_night, status)
VALUES ('108', 'Deluxe', 180.00, 'Available');



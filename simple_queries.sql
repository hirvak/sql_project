use hotel_management;
-- Show all users
SELECT * FROM Users;

-- Show only Guests
SELECT username, email, phone FROM Users WHERE role = 'guest';

-- Find staff with phone starting with '9876'
SELECT username, phone FROM Users WHERE phone LIKE '555%';

-- Count how many Managers exist
SELECT COUNT(U.user_id) AS total_managers FROM Users U JOIN Staff S ON U.user_id = S.user_id WHERE S.role = 'manager';

-- Show all guest details
SELECT * FROM Guest;

-- address = 'Mumbai' (Use actual sample addresses)
SELECT name, phone FROM Guest WHERE address LIKE '%City A%';

-- Count male and female guests
SELECT gender, COUNT(*) AS total 
FROM Guest 
GROUP BY gender;

-- Guests with Aadhar as ID proof
SELECT name, id_proof FROM Guest WHERE id_proof LIKE 'ID_A456%';

-- Show all staff
SELECT * FROM Staff;

-- Staff earning more than 30,000
SELECT name, role, salary FROM Staff WHERE salary > 30000.00;

-- Total salary paid per role
SELECT role, SUM(salary) AS total_salary FROM Staff GROUP BY role;

-- Staff working night shift
SELECT name, role FROM Staff WHERE shift = 'Night';

-- Show all rooms
SELECT * FROM Rooms;

-- Available rooms only
SELECT room_no, room_type, price_per_night FROM Rooms WHERE status = 'Available';

-- Average price for each room type
SELECT room_type, AVG(price_per_night) AS avg_price FROM Rooms GROUP BY room_type;

-- Count rooms per status
SELECT status, COUNT(*) AS total 
FROM Rooms 
GROUP BY status;

-- Show all bookings
SELECT * FROM Bookings;

-- Confirmed bookings only
SELECT G.name AS GuestName, R.room_no, B.booking_id FROM Bookings B 
JOIN Guest G ON B.guest_id = G.guest_id JOIN Rooms R ON B.room_id = R.room_id 
WHERE B.booking_status = 'Confirmed';

-- Number of guests booked per booking
SELECT booking_id, no_of_guests 
FROM Bookings;

-- Count bookings per guest
SELECT G.name, COUNT(B.booking_id) AS total_bookings FROM Bookings B 
JOIN Guest G ON B.guest_id = G.guest_id GROUP BY G.name ORDER BY total_bookings DESC;

-- Show all payments
SELECT * FROM Payment;

-- Show failed payments
SELECT booking_id, amount, payment_mode FROM Payment WHERE status = 'Failed';

-- Total paid amount
SELECT SUM(amount) AS total_paid FROM Payment WHERE status = 'Completed';

-- Payments done via Card
SELECT payment_id, booking_id, amount FROM Payment WHERE payment_mode = 'Credit Card';

-- Show all services
SELECT * FROM Services;

-- Services costing more than 50
SELECT service_name, service_price FROM Services WHERE service_price > 50.00;

-- Cheapest service
SELECT service_name, service_price FROM Services ORDER BY service_price ASC LIMIT 1;

-- Average service price
SELECT AVG(service_price) AS avg_price 
FROM Services;

-- Show all booking-service details
SELECT * FROM Booking_Service;

-- Show all services taken in booking 1
SELECT S.service_name, BS.quantity FROM Booking_Service BS JOIN Services S ON BS.service_id = S.service_id WHERE BS.booking_id = 1;

-- Count how many services each booking took
SELECT booking_id, COUNT(*) AS total_services 
FROM Booking_Service 
GROUP BY booking_id;

-- Find bookings that took more than 1 service
SELECT booking_id, COUNT(*) AS service_count FROM Booking_Service GROUP BY booking_id HAVING service_count > 1;

-- Show all reviews
SELECT * FROM Review;

-- Show reviews with rating 5
SELECT guest_id, comments FROM Review WHERE rating = 5;

-- Average rating per guest
SELECT guest_id, AVG(rating) AS avg_rating FROM Review GROUP BY guest_id;

-- Highest rating given
SELECT MAX(rating) AS highest_rating FROM Review;

-- Show all 5-star reviews with Guest Name
SELECT G.name AS GuestName, R.comments, R.review_date FROM Review R JOIN Guest G ON R.guest_id = G.guest_id WHERE R.rating = 5;


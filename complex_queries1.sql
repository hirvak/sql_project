#USER TABLE
-- 1. Users Table Queries
-- Count users by role	
SELECT role, COUNT(*) AS total_users FROM Users GROUP BY role;
-- Find roles having more than 2 users	
SELECT role, COUNT(*) AS total_users FROM Users GROUP BY role HAVING COUNT(*) > 2;
-- Show Guests with their Guest details	
SELECT U.username, G.name, G.address FROM Users U INNER JOIN Guest G ON U.user_id = G.user_id;
-- Show all users with staff info	
SELECT U.username, S.role, S.salary FROM Users U LEFT JOIN Staff S ON U.user_id = S.user_id;
-- Find users who are also Managers	
SELECT username FROM Users WHERE user_id IN (SELECT user_id FROM Staff WHERE role = 'manager');

-- 2. Guest Table Queries
-- Count guests by gender	
SELECT gender, COUNT(*) AS total FROM Guest GROUP BY gender;
-- Guests who have bookings more than 1	
SELECT G.name, COUNT(B.booking_id) AS total_bookings FROM Guest G INNER JOIN Bookings B ON G.guest_id = B.guest_id GROUP BY G.guest_id, G.name HAVING COUNT(B.booking_id) > 1;
-- Guests and their reviews	
SELECT G.name, R.rating, R.comments FROM Guest G INNER JOIN Review R ON G.guest_id = R.guest_id;
-- Show all guests and bookings	
SELECT G.name, B.booking_id, B.booking_status FROM Guest G LEFT JOIN Bookings B ON G.guest_id = B.guest_id;
-- Guests who never booked	
SELECT name FROM Guest WHERE guest_id NOT IN (SELECT guest_id FROM Bookings);

-- 3. Staff Table Queries
-- Total salary by role	
SELECT role, SUM(salary) AS total_salary FROM Staff GROUP BY role;
-- Roles with average salary > 30000	
SELECT role, AVG(salary) AS avg_salary FROM Staff GROUP BY role HAVING AVG(salary) > 30000;
-- Join Staff with Users	
SELECT U.username, S.role, S.salary FROM Staff S INNER JOIN Users U ON S.user_id = U.user_id;
-- Left join Staff with Bookings handled	
SELECT S.name, B.booking_id FROM Staff S LEFT JOIN Bookings B ON S.staff_id = B.staff_id;
-- Staff who earn more than average salary
SELECT name, salary FROM Staff WHERE salary > (SELECT AVG(salary) FROM Staff);

-- 4. Rooms Table Queries
-- Average price per room type
SELECT room_type, AVG(price_per_night) AS avg_price 
FROM Rooms 
GROUP BY room_type;

-- Room types having more than 2 rooms
SELECT room_type, COUNT(*) AS total 
FROM Rooms 
GROUP BY room_type 
HAVING COUNT(*) > 2;

-- Join Rooms with Bookings
SELECT R.room_no, B.booking_id, B.booking_status 
FROM Rooms R 
INNER JOIN Bookings B ON R.room_id = B.room_id;

-- Left join Rooms with Bookings
SELECT R.room_no, B.booking_id 
FROM Rooms R 
LEFT JOIN Bookings B ON R.room_id = B.room_id;

-- Nested: Rooms never booked
SELECT room_no 
FROM Rooms 
WHERE room_id NOT IN (SELECT room_id FROM Bookings);

-- 5. Bookings Table Queries
-- Count bookings per status
SELECT booking_status, COUNT(*) AS total 
FROM Bookings
GROUP BY booking_status;

-- Guests having > 1 confirmed booking
SELECT guest_id, COUNT(*) AS confirmed_bookings 
FROM Bookings 
WHERE booking_status = 'Confirmed' 
GROUP BY guest_id 
HAVING COUNT(*) > 1;

-- Join Bookings with Payments
SELECT B.booking_id, B.booking_status, P.status 
FROM Bookings B 
INNER JOIN Payment P ON B.booking_id = P.booking_id;

-- Left join Bookings with Reviews
SELECT B.booking_id, R.rating 
FROM Bookings B 
LEFT JOIN Review R ON B.booking_id = R.booking_id;

-- Nested: Find bookings with amount > average payment
SELECT booking_id 
FROM Bookings 
WHERE booking_id IN (
    SELECT booking_id 
    FROM Payment 
    WHERE amount > (SELECT AVG(amount) FROM Payment)
);

-- 6. Payment Table Queries
-- Total payment by mode
SELECT payment_mode, SUM(amount) AS total_amount 
FROM Payment 
GROUP BY payment_mode;

-- Payment modes with > 2 successful transactions
SELECT payment_mode, COUNT(*) AS total_success 
FROM Payment 
WHERE status = 'Pending' 
GROUP BY payment_mode 
HAVING COUNT(*) > 2;

-- Join Payment with Booking
SELECT P.payment_id, B.booking_id, P.amount, B.booking_status 
FROM Payment P 
INNER JOIN Bookings B ON P.booking_id = B.booking_id;

-- Left join Payment with Booking
SELECT B.booking_id, P.amount 
FROM Bookings B 
LEFT JOIN Payment P ON B.booking_id = P.booking_id;

-- Nested: Payments higher than average amount
SELECT payment_id, amount 
FROM Payment 
WHERE amount > (SELECT AVG(amount) FROM Payment);

-- 7. Services Table Queries
-- Count services by price category
SELECT 
    CASE 
        WHEN service_price < 50 THEN 'Low Cost' 
        WHEN service_price BETWEEN 50 AND 100 THEN 'Medium Cost' 
        ELSE 'High Cost' 
    END AS category, 
    COUNT(*) AS total 
FROM Services 
GROUP BY category;

-- Services with avg price > (avg price)
SELECT service_name, service_price 
FROM Services 
WHERE service_price > (SELECT AVG(service_price) FROM Services);

-- Join Service with Booking_Service
SELECT S.service_name, BS.booking_id, BS.quantity 
FROM Services S 
INNER JOIN Booking_Service BS ON S.service_id = BS.service_id;

-- Left join Service with Booking_Service
SELECT S.service_name, BS.booking_id 
FROM Services S 
LEFT JOIN Booking_Service BS ON S.service_id = BS.service_id;

-- 8. Booking_Service Table Queries
-- Count services per booking
SELECT booking_id, COUNT(*) AS total_services 
FROM Booking_Service 
GROUP BY booking_id;

-- Bookings that used more than 1 service
SELECT booking_id, COUNT(*) AS total_services 
FROM Booking_Service 
GROUP BY booking_id 
HAVING COUNT(*) > 1;

-- Join Booking_Service with Service
SELECT BS.booking_id, S.service_name, BS.quantity 
FROM Booking_Service BS 
INNER JOIN Services S ON BS.service_id = S.service_id;

-- Left join Booking with Booking_Service
SELECT B.booking_id, BS.service_id 
FROM Bookings B 
LEFT JOIN Booking_Service BS ON B.booking_id = BS.booking_id;

-- Nested: Find booking with max services
SELECT booking_id 
FROM Booking_Service 
GROUP BY booking_id 
HAVING COUNT(*) = (
    SELECT MAX(service_count) 
    FROM (
        SELECT COUNT(*) AS service_count 
        FROM Booking_Service 
        GROUP BY booking_id
    ) AS temp
);

-- 9. Review Table Queries
-- Average rating per guest
SELECT guest_id, AVG(rating) AS avg_rating 
FROM Review 
GROUP BY guest_id;

-- Guests who gave more than 1 review
SELECT guest_id, COUNT(*) AS total_reviews 
FROM Review 
GROUP BY guest_id 
HAVING COUNT(*) > 1;

-- Join Reviews with Booking
SELECT R.review_id, B.booking_id, R.rating, R.comments 
FROM Review R 
INNER JOIN Bookings B ON R.booking_id = B.booking_id;

-- Left join Reviews with Guest
SELECT G.name, R.rating, R.comments 
FROM Guest G 
LEFT JOIN Review R ON G.guest_id = R.guest_id;

-- Nested: Highest rated guest
SELECT guest_id 
FROM Review
WHERE rating = (SELECT MAX(rating) FROM Review);

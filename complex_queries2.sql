-- Bookings handled by each staff (GROUP BY)
SELECT s.staff_id, s.name, COUNT(b.booking_id) AS bookings_handled
FROM Staff s
LEFT JOIN Bookings b ON s.staff_id = b.staff_id
GROUP BY s.staff_id, s.name;
-- Feature: Measure staff performance.


-- Most booked room type (GROUP BY + HAVING + Subquery)
SELECT r.room_type, COUNT(b.booking_id) AS total_booked
FROM Rooms r
INNER JOIN Bookings b ON r.room_id = b.room_id
GROUP BY r.room_type
HAVING COUNT(b.booking_id) = (
    SELECT MAX(room_count)
    FROM (
        SELECT COUNT(*) AS room_count
        FROM Bookings
        GROUP BY room_id
    ) AS temp
);
-- Feature: Analyze room demand.

SELECT r.room_id, r.room_type, r.status
FROM Rooms r
JOIN Bookings b ON r.room_id = b.room_id
WHERE r.status = 'Available';



-- Most used service
SELECT S.service_name, COUNT(bs.service_id) AS usage_count
FROM Services S
JOIN Booking_Service bs ON S.service_id = bs.service_id
GROUP BY S.service_name
HAVING COUNT(bs.service_id) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(bs2.service_id) AS cnt
        FROM Booking_Service bs2
        GROUP BY bs2.service_id
    ) AS t
);
-- Track popular services.

-- Count bookings per guest
SELECT G.name, COUNT(B.booking_id) AS total_bookings FROM Bookings B 
JOIN Guest G ON B.guest_id = G.guest_id GROUP BY G.name ORDER BY total_bookings DESC;

-- Guests who never booked	
SELECT g.guest_id, g.name
FROM Guest g
LEFT JOIN Bookings b ON g.guest_id = b.guest_id
WHERE b.booking_id IS NULL;

-- Revenue collected per payment mode (GROUP BY + HAVING)
SELECT payment_mode, SUM(amount) AS total_revenue
FROM Payment
GROUP BY payment_mode
HAVING SUM(amount) > 1000;
-- Feature: Track revenue sources.

SELECT payment_mode, SUM(amount)  AS total_revenue
FROM Payment
GROUP BY payment_mode WITH ROLLUP;

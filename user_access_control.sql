-- Admin user: full access
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@123';
GRANT ALL PRIVILEGES ON hotel_management.* TO 'admin_user'@'localhost';

-- Staff user: read and update only
CREATE USER 'staff_user'@'localhost' IDENTIFIED BY 'Staff@123';
GRANT SELECT, UPDATE ON hotel_management.Rooms TO 'staff_user'@'localhost';
GRANT SELECT, UPDATE ON hotel_management.Bookings TO 'staff_user'@'localhost';
GRANT SELECT ON hotel_management.Guest TO 'staff_user'@'localhost';
GRANT INSERT ON hotel_management.Payment TO 'staff_user'@'localhost'; -- staff also record payments when guests check in or out.
FLUSH PRIVILEGES;


-- Guest user: only read access to own info
CREATE USER 'guest_user'@'localhost' IDENTIFIED BY 'Guest@123';
GRANT SELECT ON hotel_management.Guest_Bookings TO 'guest_user'@'localhost';
GRANT INSERT ON hotel_management.Review TO 'guest_user'@'localhost';
FLUSH PRIVILEGES;

-- Check privileges for a user
SHOW GRANTS FOR 'staff_user'@'localhost';
SHOW GRANTS FOR 'guest_user'@'localhost';

SELECT User, Host FROM mysql.user;

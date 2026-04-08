-- ============================================================
-- HOTEL MANAGEMENT SYSTEM
-- PlatinumRx Assignment - Phase 1, Part A
-- ============================================================

-- ------------------------------------------------------------
-- SCHEMA CREATION
-- ------------------------------------------------------------

CREATE TABLE users (
    user_id   INT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    email     VARCHAR(150) UNIQUE NOT NULL,
    phone     VARCHAR(20),
    created_at DATE
);

CREATE TABLE rooms (
    room_id     INT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL,
    room_type   VARCHAR(50),   -- e.g. Standard, Deluxe, Suite
    floor       INT,
    rate_per_night DECIMAL(10,2)
);

CREATE TABLE bookings (
    booking_id   INT PRIMARY KEY,
    user_id      INT REFERENCES users(user_id),
    room_id      INT REFERENCES rooms(room_id),
    check_in     DATE NOT NULL,
    check_out    DATE NOT NULL,
    booking_date DATE NOT NULL,
    status       VARCHAR(20) DEFAULT 'confirmed'
);

CREATE TABLE items (
    item_id   INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category  VARCHAR(50),   -- e.g. Food, Beverage, Service
    rate      DECIMAL(10,2) NOT NULL
);

CREATE TABLE booking_commercials (
    commercial_id INT PRIMARY KEY,
    booking_id    INT REFERENCES bookings(booking_id),
    item_id       INT REFERENCES items(item_id),
    quantity      INT NOT NULL,
    order_date    DATE NOT NULL
);

-- ------------------------------------------------------------
-- SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO users VALUES
(1, 'Alice Johnson',  'alice@example.com',  '9000000001', '2021-01-15'),
(2, 'Bob Smith',      'bob@example.com',    '9000000002', '2021-03-10'),
(3, 'Carol White',   'carol@example.com',  '9000000003', '2021-06-20'),
(4, 'David Brown',   'david@example.com',  '9000000004', '2021-08-05'),
(5, 'Eva Green',     'eva@example.com',    '9000000005', '2021-09-18');

INSERT INTO rooms VALUES
(101, '101', 'Standard', 1, 2000.00),
(102, '102', 'Standard', 1, 2000.00),
(201, '201', 'Deluxe',   2, 3500.00),
(202, '202', 'Deluxe',   2, 3500.00),
(301, '301', 'Suite',    3, 6000.00);

INSERT INTO bookings VALUES
(1001, 1, 101, '2021-10-01', '2021-10-05', '2021-09-25', 'confirmed'),
(1002, 2, 201, '2021-11-03', '2021-11-07', '2021-10-28', 'confirmed'),
(1003, 3, 301, '2021-11-10', '2021-11-15', '2021-11-01', 'confirmed'),
(1004, 4, 102, '2021-11-20', '2021-11-22', '2021-11-15', 'confirmed'),
(1005, 5, 202, '2021-12-01', '2021-12-05', '2021-11-25', 'confirmed'),
(1006, 1, 301, '2021-12-15', '2021-12-18', '2021-12-10', 'confirmed'),
(1007, 2, 101, '2022-01-05', '2022-01-08', '2021-12-30', 'confirmed');

INSERT INTO items VALUES
(1, 'Club Sandwich',    'Food',      350.00),
(2, 'Pasta',            'Food',      280.00),
(3, 'Fresh Juice',      'Beverage',  150.00),
(4, 'Soft Drink',       'Beverage',   80.00),
(5, 'Laundry Service',  'Service',   200.00),
(6, 'Spa Session',      'Service',   800.00),
(7, 'Breakfast Buffet', 'Food',      450.00);

INSERT INTO booking_commercials VALUES
(1, 1001, 1, 2, '2021-10-02'),
(2, 1001, 3, 3, '2021-10-03'),
(3, 1002, 7, 4, '2021-11-04'),
(4, 1002, 6, 1, '2021-11-05'),
(5, 1002, 2, 2, '2021-11-06'),
(6, 1003, 7, 5, '2021-11-11'),
(7, 1003, 6, 2, '2021-11-12'),
(8, 1003, 5, 3, '2021-11-13'),
(9, 1004, 1, 1, '2021-11-21'),
(10, 1004, 4, 4, '2021-11-21'),
(11, 1005, 7, 4, '2021-12-02'),
(12, 1005, 3, 5, '2021-12-03'),
(13, 1006, 6, 3, '2021-12-16'),
(14, 1006, 1, 2, '2021-12-17'),
(15, 1007, 7, 2, '2022-01-06');

-- ============================================================
-- QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Which room was booked last (most recent booking_date)?
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    r.room_number,
    r.room_type,
    u.name        AS guest_name,
    b.booking_date
FROM bookings b
JOIN rooms r ON b.room_id   = r.room_id
JOIN users u ON b.user_id   = u.user_id
WHERE b.booking_date = (SELECT MAX(booking_date) FROM bookings);

-- ------------------------------------------------------------
-- Q2: Total billing for each booking made in November 2021
--     (amount = quantity * item rate)
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    u.name                            AS guest_name,
    r.room_number,
    SUM(bc.quantity * i.rate)         AS total_bill
FROM bookings b
JOIN users               u  ON b.user_id     = u.user_id
JOIN rooms               r  ON b.room_id     = r.room_id
JOIN booking_commercials bc ON b.booking_id  = bc.booking_id
JOIN items               i  ON bc.item_id    = i.item_id
WHERE b.check_in BETWEEN '2021-11-01' AND '2021-11-30'
GROUP BY b.booking_id, u.name, r.room_number
ORDER BY total_bill DESC;

-- ------------------------------------------------------------
-- Q3: Bookings whose total bill exceeds 1000
-- ------------------------------------------------------------
SELECT
    b.booking_id,
    u.name                      AS guest_name,
    SUM(bc.quantity * i.rate)   AS total_bill
FROM bookings b
JOIN users               u  ON b.user_id    = u.user_id
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items               i  ON bc.item_id   = i.item_id
GROUP BY b.booking_id, u.name
HAVING SUM(bc.quantity * i.rate) > 1000
ORDER BY total_bill DESC;

-- ------------------------------------------------------------
-- Q4: Most and least ordered item per month
-- ------------------------------------------------------------
WITH monthly_orders AS (
    SELECT
        TO_CHAR(bc.order_date, 'YYYY-MM')  AS order_month,
        i.item_name,
        SUM(bc.quantity)                   AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY TO_CHAR(bc.order_date, 'YYYY-MM'), i.item_name
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty DESC) AS rnk_desc,
        RANK() OVER (PARTITION BY order_month ORDER BY total_qty ASC)  AS rnk_asc
    FROM monthly_orders
)
SELECT
    order_month,
    MAX(CASE WHEN rnk_desc = 1 THEN item_name END) AS most_ordered_item,
    MAX(CASE WHEN rnk_asc  = 1 THEN item_name END) AS least_ordered_item
FROM ranked
GROUP BY order_month
ORDER BY order_month;

-- ------------------------------------------------------------
-- Q5: Booking with the 2nd highest total bill
-- ------------------------------------------------------------
WITH bill_totals AS (
    SELECT
        b.booking_id,
        u.name                      AS guest_name,
        SUM(bc.quantity * i.rate)   AS total_bill,
        RANK() OVER (ORDER BY SUM(bc.quantity * i.rate) DESC) AS bill_rank
    FROM bookings b
    JOIN users               u  ON b.user_id    = u.user_id
    JOIN booking_commercials bc ON b.booking_id = bc.booking_id
    JOIN items               i  ON bc.item_id   = i.item_id
    GROUP BY b.booking_id, u.name
)
SELECT booking_id, guest_name, total_bill
FROM bill_totals
WHERE bill_rank = 2;

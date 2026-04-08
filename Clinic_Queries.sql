-- ============================================================
-- CLINIC MANAGEMENT SYSTEM
-- PlatinumRx Assignment - Phase 1, Part B
-- ============================================================

-- ------------------------------------------------------------
-- SCHEMA CREATION
-- ------------------------------------------------------------

CREATE TABLE doctors (
    doctor_id   INT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    specialty   VARCHAR(100),
    phone       VARCHAR(20)
);

CREATE TABLE patients (
    patient_id  INT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    dob         DATE,
    phone       VARCHAR(20),
    email       VARCHAR(150)
);

CREATE TABLE appointments (
    appointment_id  INT PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    doctor_id       INT REFERENCES doctors(doctor_id),
    appointment_date DATE NOT NULL,
    status          VARCHAR(20) DEFAULT 'scheduled'  -- scheduled / completed / cancelled
);

CREATE TABLE clinic_sales (
    sale_id         INT PRIMARY KEY,
    appointment_id  INT REFERENCES appointments(appointment_id),
    sales_channel   VARCHAR(50) NOT NULL,  -- e.g. Walk-In, Online, Insurance
    amount          DECIMAL(10,2) NOT NULL,
    sale_date       DATE NOT NULL
);

CREATE TABLE expenses (
    expense_id      INT PRIMARY KEY,
    category        VARCHAR(100),   -- e.g. Rent, Salaries, Supplies
    amount          DECIMAL(10,2) NOT NULL,
    expense_date    DATE NOT NULL
);

-- ------------------------------------------------------------
-- SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO doctors VALUES
(1, 'Dr. Priya Nair',    'General Physician', '9100000001'),
(2, 'Dr. Arjun Mehta',   'Dermatology',       '9100000002'),
(3, 'Dr. Sunita Rao',    'Pediatrics',        '9100000003');

INSERT INTO patients VALUES
(1, 'Ravi Kumar',    '1985-04-12', '9200000001', 'ravi@mail.com'),
(2, 'Meena Sharma',  '1990-08-25', '9200000002', 'meena@mail.com'),
(3, 'Arjun Das',     '2001-11-30', '9200000003', 'arjun@mail.com'),
(4, 'Lakshmi Iyer',  '1978-03-17', '9200000004', 'lakshmi@mail.com'),
(5, 'Vikram Patel',  '1995-07-09', '9200000005', 'vikram@mail.com'),
(6, 'Priya Menon',   '2000-01-22', '9200000006', 'priya@mail.com');

INSERT INTO appointments VALUES
(101, 1, 1, '2024-01-10', 'completed'),
(102, 2, 2, '2024-01-15', 'completed'),
(103, 3, 3, '2024-02-05', 'completed'),
(104, 4, 1, '2024-02-18', 'completed'),
(105, 5, 2, '2024-03-03', 'completed'),
(106, 6, 3, '2024-03-22', 'completed'),
(107, 1, 2, '2024-04-08', 'completed'),
(108, 2, 1, '2024-04-20', 'completed'),
(109, 3, 3, '2024-05-11', 'completed'),
(110, 4, 2, '2024-05-28', 'completed');

INSERT INTO clinic_sales VALUES
(1,  101, 'Walk-In',   500.00, '2024-01-10'),
(2,  102, 'Online',    750.00, '2024-01-15'),
(3,  103, 'Insurance', 1200.00,'2024-02-05'),
(4,  104, 'Walk-In',   450.00, '2024-02-18'),
(5,  105, 'Online',    900.00, '2024-03-03'),
(6,  106, 'Insurance', 1500.00,'2024-03-22'),
(7,  107, 'Walk-In',   600.00, '2024-04-08'),
(8,  108, 'Online',    850.00, '2024-04-20'),
(9,  109, 'Insurance', 1100.00,'2024-05-11'),
(10, 110, 'Walk-In',   700.00, '2024-05-28');

INSERT INTO expenses VALUES
(1, 'Rent',      20000.00, '2024-01-31'),
(2, 'Salaries',  45000.00, '2024-01-31'),
(3, 'Supplies',   3000.00, '2024-01-20'),
(4, 'Rent',      20000.00, '2024-02-28'),
(5, 'Salaries',  45000.00, '2024-02-28'),
(6, 'Supplies',   2500.00, '2024-02-15'),
(7, 'Rent',      20000.00, '2024-03-31'),
(8, 'Salaries',  45000.00, '2024-03-31'),
(9, 'Utilities',  1800.00, '2024-03-25'),
(10,'Rent',      20000.00, '2024-04-30'),
(11,'Salaries',  45000.00, '2024-04-30'),
(12,'Supplies',   3200.00, '2024-04-18'),
(13,'Rent',      20000.00, '2024-05-31'),
(14,'Salaries',  45000.00, '2024-05-31'),
(15,'Utilities',  2000.00, '2024-05-20');

-- ============================================================
-- QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Q1: Total revenue by sales channel
-- ------------------------------------------------------------
SELECT
    sales_channel,
    COUNT(sale_id)       AS total_transactions,
    SUM(amount)          AS total_revenue
FROM clinic_sales
GROUP BY sales_channel
ORDER BY total_revenue DESC;

-- ------------------------------------------------------------
-- Q2: Monthly revenue trend
-- ------------------------------------------------------------
SELECT
    TO_CHAR(sale_date, 'YYYY-MM')  AS month,
    SUM(amount)                     AS monthly_revenue
FROM clinic_sales
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month;

-- ------------------------------------------------------------
-- Q3: Monthly Profit / Loss  (Revenue - Expenses)
-- ------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        TO_CHAR(sale_date, 'YYYY-MM')   AS month,
        SUM(amount)                      AS revenue
    FROM clinic_sales
    GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
),
monthly_expenses AS (
    SELECT
        TO_CHAR(expense_date, 'YYYY-MM') AS month,
        SUM(amount)                       AS expenses
    FROM expenses
    GROUP BY TO_CHAR(expense_date, 'YYYY-MM')
)
SELECT
    COALESCE(r.month, e.month)          AS month,
    COALESCE(r.revenue,  0)             AS total_revenue,
    COALESCE(e.expenses, 0)             AS total_expenses,
    COALESCE(r.revenue, 0)
        - COALESCE(e.expenses, 0)       AS profit_loss,
    CASE
        WHEN COALESCE(r.revenue, 0) - COALESCE(e.expenses, 0) >= 0
        THEN 'Profit'
        ELSE 'Loss'
    END                                 AS status
FROM monthly_revenue   r
FULL OUTER JOIN monthly_expenses e ON r.month = e.month
ORDER BY month;

-- ------------------------------------------------------------
-- Q4: Doctor with the highest number of completed appointments
-- ------------------------------------------------------------
SELECT
    d.name              AS doctor_name,
    d.specialty,
    COUNT(a.appointment_id) AS completed_appointments
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.status = 'completed'
GROUP BY d.doctor_id, d.name, d.specialty
ORDER BY completed_appointments DESC
LIMIT 1;

-- ------------------------------------------------------------
-- Q5: Patients with more than one appointment
-- ------------------------------------------------------------
SELECT
    p.name                  AS patient_name,
    COUNT(a.appointment_id) AS total_appointments
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.name
HAVING COUNT(a.appointment_id) > 1
ORDER BY total_appointments DESC;

# PlatinumRx Data Analyst Assignment

## Overview
This repository contains all deliverables for the PlatinumRx assessment covering SQL, Spreadsheet, and Python proficiency.

---

## 📁 Folder Structure
```
├── SQL/
│   ├── hotel_management.sql      # Phase 1 – Part A: Hotel System
│   └── clinic_management.sql     # Phase 1 – Part B: Clinic System
├── Spreadsheets/
│   └── Ticket_Analysis.xlsx      # Phase 2 – Ticket & Feedback Analysis
├── Python/
│   ├── 01_Time_Converter.py      # Phase 3 – Step 1: Minutes → Hrs & Mins
│   └── 02_Remove_Duplicates.py   # Phase 3 – Step 2: Remove Duplicate Characters
└── README.md
```

---

## Phase 1 – SQL

### Part A: Hotel Management System (`hotel_management.sql`)

**Tables Created:**  
`users`, `rooms`, `bookings`, `items`, `booking_commercials`

| # | Question | Approach |
|---|----------|----------|
| Q1 | Last booked room | Subquery with `MAX(booking_date)` |
| Q2 | Billing in Nov 2021 | `JOIN` 3 tables + `SUM(quantity * rate)` |
| Q3 | Bills > 1000 | `GROUP BY` + `HAVING SUM(...) > 1000` |
| Q4 | Most/least ordered item per month | Window `RANK()` partitioned by month |
| Q5 | 2nd highest bill | Window `RANK()` on total bill, filter `bill_rank = 2` |

### Part B: Clinic Management System (`clinic_management.sql`)

**Tables Created:**  
`doctors`, `patients`, `appointments`, `clinic_sales`, `expenses`

| # | Question | Approach |
|---|----------|----------|
| Q1 | Revenue by channel | `GROUP BY sales_channel` + `SUM(amount)` |
| Q2 | Monthly revenue trend | `GROUP BY month` + `SUM(amount)` |
| Q3 | Monthly Profit / Loss | Two CTEs (revenue + expenses) joined on month, subtracted |
| Q4 | Top doctor by appointments | `GROUP BY` + `ORDER BY DESC LIMIT 1` |
| Q5 | Patients with 2+ appointments | `GROUP BY` + `HAVING COUNT > 1` |

**Assumptions:**
- PostgreSQL dialect used (`TO_CHAR`, `FULL OUTER JOIN`)
- For MySQL, replace `TO_CHAR(date, 'YYYY-MM')` with `DATE_FORMAT(date, '%Y-%m')`

---

## Phase 2 – Spreadsheet (`Ticket_Analysis.xlsx`)

**Sheets:**
| Sheet | Purpose |
|-------|---------|
| `ticket` | Raw ticket data (cms_id, outlet, dates, status) |
| `feedbacks` | Feedback data with computed columns |
| `Analysis` | Summary counts per outlet |

**Q1 – Pulling ticket created_at into feedbacks:**
```excel
=VLOOKUP(B2, ticket!$A:$G, 5, 0)
```
Uses `cms_id` (col B in feedbacks) to look up `created_at` (col 5) from the ticket sheet.

**Q2 – Same Day / Same Hour flags:**
```excel
Same Day?  =IF(INT(D2)=INT(E2), "Yes", "No")
Same Hour? =IF(AND(D2<>"", HOUR(D2)=HOUR(E2)), "Yes", "No")
```
`INT()` strips the time fraction to isolate the date portion.
`HOUR()` extracts the hour integer from both timestamps.

**Summary counts use `COUNTIFS`:**
```excel
=COUNTIFS(feedbacks!$C:$C, "Outlet A", feedbacks!$H:$H, "Yes")
```

---

## Phase 3 – Python

### `01_Time_Converter.py`
Converts an integer number of minutes to a readable format.

**Core Logic:**
```python
hours             = total_minutes // 60   # integer division
remaining_minutes = total_minutes %  60   # modulo
```

**Examples:**
| Input | Output |
|-------|--------|
| 130 | 2 hrs 10 minutes |
| 60  | 1 hrs |
| 45  | 45 minutes |
| 0   | 0 minutes |

### `02_Remove_Duplicates.py`
Removes duplicate characters from a string, preserving first-occurrence order.

**Core Logic:**
```python
result = ""
for char in text:
    if char not in result:
        result += char
```

**Examples:**
| Input | Output |
|-------|--------|
| "programming" | "progamin" |
| "aabbcc" | "abc" |
| "hello world" | "helo wrd" |

---

## How to Run

### SQL
1. Open MySQL Workbench / pgAdmin / DB Fiddle
2. Run the full `.sql` file (schema + inserts + queries)
3. Each query is clearly labelled Q1–Q5

### Python
```bash
python Python/01_Time_Converter.py
python Python/02_Remove_Duplicates.py
```
Requires Python 3.x — no external libraries needed.

### Spreadsheet
Open `Spreadsheets/Ticket_Analysis.xlsx` in Microsoft Excel or Google Sheets.

---

## Author
Submitted as part of the PlatinumRx Data Analyst Assessment.

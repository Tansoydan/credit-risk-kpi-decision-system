
-- SQLite schema v1 (Accepted loans only)

-- =========================
-- 1) RAW LANDING TABLE
-- =========================

DROP TABLE IF EXISTS raw_loans;
CREATE TABLE raw_loans (
  row_id INTEGER PRIMARY KEY AUTOINCREMENT,

  -- identifiers / dates
  id TEXT,
  issue_d TEXT,
  earliest_cr_line TEXT,
  last_pymnt_d TEXT,
  last_credit_pull_d TEXT,

  -- outcome
  loan_status TEXT,

  -- loan terms
  loan_amnt TEXT,
  funded_amnt TEXT,
  term TEXT,
  int_rate TEXT,
  installment TEXT,

  -- borrower profile
  grade TEXT,
  sub_grade TEXT,
  emp_length TEXT,
  emp_title TEXT,
  home_ownership TEXT,
  annual_inc TEXT,
  verification_status TEXT,
  purpose TEXT,
  addr_state TEXT,

  -- credit / behaviour
  dti TEXT,
  delinq_2yrs TEXT,
  fico_range_low TEXT,
  fico_range_high TEXT,
  inq_last_6mths TEXT,
  open_acc TEXT,
  pub_rec TEXT,
  revol_bal TEXT,
  revol_util TEXT,
  total_acc TEXT,

  -- payments (helpful for KPI/profit proxies later)
  total_pymnt TEXT,
  total_rec_prncp TEXT,
  total_rec_int TEXT,
  last_pymnt_amnt TEXT
);

-- =========================
-- 2) CLEAN ANALYTICS TABLE
-- =========================
-- Types + target label. Only keep FINAL outcomes for modelling:
--   default_flag = 1 for Charged Off
--   default_flag = 0 for Fully Paid
DROP TABLE IF EXISTS clean_loans;
CREATE TABLE clean_loans AS
SELECT
  row_id,

  -- keep identifiers as text
  id,
  issue_d,
  addr_state,
  purpose,

  -- numeric conversions
  CAST(loan_amnt AS REAL) AS loan_amnt,
  CAST(funded_amnt AS REAL) AS funded_amnt,

  term,

  CAST(REPLACE(int_rate, '%', '') AS REAL) AS int_rate_pct,
  CAST(installment AS REAL) AS installment,

  grade,
  sub_grade,
  emp_length,
  home_ownership,

  CAST(annual_inc AS REAL) AS annual_inc,
  verification_status,

  CAST(dti AS REAL) AS dti,
  CAST(delinq_2yrs AS INTEGER) AS delinq_2yrs,
  CAST(fico_range_low AS INTEGER) AS fico_low,
  CAST(fico_range_high AS INTEGER) AS fico_high,
  CAST(inq_last_6mths AS INTEGER) AS inq_last_6mths,
  CAST(open_acc AS INTEGER) AS open_acc,
  CAST(pub_rec AS INTEGER) AS pub_rec,
  CAST(revol_bal AS REAL) AS revol_bal,
  CAST(REPLACE(revol_util, '%', '') AS REAL) AS revol_util_pct,
  CAST(total_acc AS INTEGER) AS total_acc,

  loan_status,

  CAST(total_pymnt AS REAL) AS total_pymnt,
  CAST(total_rec_prncp AS REAL) AS total_rec_prncp,
  CAST(total_rec_int AS REAL) AS total_rec_int,
  CAST(last_pymnt_amnt AS REAL) AS last_pymnt_amnt,

  CASE
    WHEN loan_status = 'Charged Off' THEN 1
    WHEN loan_status = 'Fully Paid'  THEN 0
    ELSE NULL
  END AS default_flag

FROM raw_loans
WHERE loan_status IN ('Charged Off', 'Fully Paid');

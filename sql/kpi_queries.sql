-- Uses clean_loans (accepted loans with final outcomes only)

-- 1) Dataset size + class balance
SELECT
  COUNT(*) AS n_loans,
  SUM(default_flag) AS n_default,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct
FROM clean_loans;

-- 2) Basic lending metrics
SELECT
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
  ROUND(AVG(int_rate_pct), 2) AS avg_interest_rate_pct,
  ROUND(AVG(annual_inc), 2) AS avg_annual_income
FROM clean_loans;

-- 3) Default rate by grade (risk segmentation)
SELECT
  grade,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt
FROM clean_loans
GROUP BY grade
ORDER BY grade;

-- 4) Default rate by sub_grade (finer segmentation)
SELECT
  sub_grade,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct
FROM clean_loans
GROUP BY sub_grade
ORDER BY sub_grade;

-- 5) Default rate by purpose
SELECT
  purpose,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt
FROM clean_loans
GROUP BY purpose
HAVING COUNT(*) >= 500
ORDER BY default_rate_pct DESC;

-- 6) Risk by income band (simple bucketing)
WITH income_bands AS (
  SELECT
    CASE
      WHEN annual_inc < 30000 THEN '<30k'
      WHEN annual_inc < 60000 THEN '30–60k'
      WHEN annual_inc < 100000 THEN '60–100k'
      WHEN annual_inc < 150000 THEN '100–150k'
      ELSE '150k+'
    END AS income_band,
    default_flag,
    loan_amnt
  FROM clean_loans
  WHERE annual_inc IS NOT NULL
)
SELECT
  income_band,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt
FROM income_bands
GROUP BY income_band
ORDER BY n DESC;

-- 7) Simple profit proxy (very rough, but great for portfolio thinking)
-- Net = total_rec_int - (default_flag * loan_amnt)
-- (assumes full principal loss on default; we’ll refine later with LGD/EAD)
SELECT
  ROUND(AVG(total_rec_int), 2) AS avg_interest_received,
  ROUND(AVG(CASE WHEN default_flag = 1 THEN loan_amnt ELSE 0 END), 2) AS avg_principal_at_risk,
  ROUND(AVG(total_rec_int - CASE WHEN default_flag = 1 THEN loan_amnt ELSE 0 END), 2) AS avg_net_profit_proxy
FROM clean_loans
WHERE total_rec_int IS NOT NULL AND loan_amnt IS NOT NULL;

-- 8) Vintage view (by issue month string)
-- issue_d is often like "Dec-2016" in LendingClub datasets.
SELECT
  issue_d,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amnt
FROM clean_loans
GROUP BY issue_d
HAVING COUNT(*) >= 500
ORDER BY issue_d;

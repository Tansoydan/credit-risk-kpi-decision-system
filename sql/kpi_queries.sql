-- Uses clean_loans (accepted loans with final outcomes only)

-- 1) Dataset size + class balance
SELECT
  COUNT(*) AS n_loans,
  SUM(default_flag) AS n_default,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct
FROM clean_loans
WHERE default_flag IS NOT NULL;

-- 2) Basic lending metrics
SELECT
  ROUND(AVG(loan_amnt), 2) AS avg_loan_amount,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amount,
  ROUND(AVG(int_rate_pct), 2) AS avg_interest_rate_pct,
  ROUND(AVG(annual_inc), 2) AS avg_annual_income,
  ROUND(AVG(dti), 2) AS avg_dti,
  ROUND(AVG((fico_low + fico_high) / 2.0), 0) AS avg_fico
FROM clean_loans
WHERE default_flag IS NOT NULL;

-- 3) Default rate by grade (risk segmentation)
SELECT
  grade,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amnt,
  ROUND(AVG(int_rate_pct), 2) AS avg_int_rate_pct,
  ROUND(AVG((fico_low + fico_high) / 2.0), 0) AS avg_fico
FROM clean_loans
WHERE default_flag IS NOT NULL
GROUP BY grade
ORDER BY grade;

-- 4) Default rate by sub_grade (finer segmentation) + sample filter
SELECT
  sub_grade,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(int_rate_pct), 2) AS avg_int_rate_pct
FROM clean_loans
WHERE default_flag IS NOT NULL
GROUP BY sub_grade
HAVING COUNT(*) >= 1000
ORDER BY sub_grade;

-- 5) Default rate by term (36 vs 60 months)
SELECT
  term,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amnt,
  ROUND(AVG(int_rate_pct), 2) AS avg_int_rate_pct
FROM clean_loans
WHERE default_flag IS NOT NULL
GROUP BY term
ORDER BY term;

-- 6) Default rate by purpose (min sample)
SELECT
  COALESCE(NULLIF(TRIM(purpose), ''), 'Unknown') AS purpose,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amnt
FROM clean_loans
WHERE default_flag IS NOT NULL
GROUP BY COALESCE(NULLIF(TRIM(purpose), ''), 'Unknown')
HAVING COUNT(*) >= 500
ORDER BY default_rate_pct DESC;

-- 7) Risk by income band (keep Unknowns + logical ordering)
WITH income_bands AS (
  SELECT
    CASE
      WHEN annual_inc IS NULL THEN 'Unknown'
      WHEN annual_inc < 30000 THEN '<30k'
      WHEN annual_inc < 60000 THEN '30–60k'
      WHEN annual_inc < 100000 THEN '60–100k'
      WHEN annual_inc < 150000 THEN '100–150k'
      ELSE '150k+'
    END AS income_band,
    default_flag,
    funded_amnt
  FROM clean_loans
)
SELECT
  income_band,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amnt
FROM income_bands
WHERE default_flag IS NOT NULL
GROUP BY income_band
ORDER BY
  CASE income_band
    WHEN '<30k' THEN 1
    WHEN '30–60k' THEN 2
    WHEN '60–100k' THEN 3
    WHEN '100–150k' THEN 4
    WHEN '150k+' THEN 5
    ELSE 6
  END;

-- 8) Default rate by FICO band
WITH fico_bands AS (
  SELECT
    CASE
      WHEN (fico_low + fico_high) / 2.0 < 620 THEN '<620'
      WHEN (fico_low + fico_high) / 2.0 < 660 THEN '620–659'
      WHEN (fico_low + fico_high) / 2.0 < 700 THEN '660–699'
      WHEN (fico_low + fico_high) / 2.0 < 740 THEN '700–739'
      ELSE '740+'
    END AS fico_band,
    default_flag,
    funded_amnt
  FROM clean_loans
  WHERE fico_low IS NOT NULL AND fico_high IS NOT NULL
)
SELECT
  fico_band,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(funded_amnt), 2) AS avg_funded_amnt
FROM fico_bands
WHERE default_flag IS NOT NULL
GROUP BY fico_band
ORDER BY
  CASE fico_band
    WHEN '<620' THEN 1
    WHEN '620–659' THEN 2
    WHEN '660–699' THEN 3
    WHEN '700–739' THEN 4
    ELSE 5
  END;

-- 9) Net cash profit proxy (portfolio view)
SELECT
  COUNT(*) AS n,
  ROUND(AVG(total_pymnt - funded_amnt), 2) AS avg_net_cash_profit,
  ROUND(SUM(total_pymnt - funded_amnt), 2) AS total_net_cash_profit,
  ROUND(100.0 * SUM(total_pymnt - funded_amnt) / NULLIF(SUM(funded_amnt), 0), 2) AS net_profit_pct_of_funded
FROM clean_loans
WHERE default_flag IS NOT NULL
  AND total_pymnt IS NOT NULL
  AND funded_amnt IS NOT NULL;

-- 10) Net cash profit by grade (risk-adjusted contribution)
SELECT
  grade,
  COUNT(*) AS n,
  ROUND(100.0 * AVG(default_flag), 2) AS default_rate_pct,
  ROUND(AVG(total_pymnt - funded_amnt), 2) AS avg_net_cash_profit,
  ROUND(SUM(total_pymnt - funded_amnt), 2) AS total_net_cash_profit,
  ROUND(100.0 * AVG((total_pymnt - funded_amnt) / NULLIF(funded_amnt, 0)), 2) AS avg_profit_pct
FROM clean_loans
WHERE default_flag IS NOT NULL
  AND total_pymnt IS NOT NULL
  AND funded_amnt IS NOT NULL
GROUP BY grade
ORDER BY grade;

-- 11) Interest margin proxy (interest + late fees - principal loss net recoveries)
SELECT
  COUNT(*) AS n,
  ROUND(AVG(total_rec_int + total_rec_late_fee), 2) AS avg_interest_plus_late,
  ROUND(AVG(CASE WHEN default_flag = 1 THEN (funded_amnt - total_rec_prncp - recoveries) ELSE 0 END), 2) AS avg_principal_loss_net_recoveries,
  ROUND(
    AVG((total_rec_int + total_rec_late_fee) - CASE WHEN default_flag = 1 THEN (funded_amnt - total_rec_prncp - recoveries) ELSE 0 END),
    2
  ) AS avg_net_margin_proxy
FROM clean_loans
WHERE default_flag IS NOT NULL
  AND funded_amnt IS NOT NULL
  AND total_rec_prncp IS NOT NULL
  AND total_rec_int IS NOT NULL
  AND total_rec_late_fee IS NOT NULL
  AND recoveries IS NOT NULL;

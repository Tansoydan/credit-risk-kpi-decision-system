DROP TABLE IF EXISTS clean_loans;

CREATE TABLE clean_loans AS
SELECT
  row_id,
  id,
  member_id,

  issue_d,
  addr_state,
  purpose,
  grade,
  sub_grade,
  term,

  CAST(loan_amnt AS REAL) AS loan_amnt,
  CAST(funded_amnt AS REAL) AS funded_amnt,
  CAST(funded_amnt_inv AS REAL) AS funded_amnt_inv,

  CAST(REPLACE(int_rate, '%', '') AS REAL) AS int_rate_pct,
  CAST(installment AS REAL) AS installment,

  emp_length,
  home_ownership,
  CAST(annual_inc AS REAL) AS annual_inc,
  verification_status,

  CAST(dti AS REAL) AS dti,
  CAST(delinq_2yrs AS INTEGER) AS delinq_2yrs,

  earliest_cr_line,
  CAST(fico_range_low AS INTEGER) AS fico_low,
  CAST(fico_range_high AS INTEGER) AS fico_high,

  CAST(inq_last_6mths AS INTEGER) AS inq_last_6mths,
  CAST(open_acc AS INTEGER) AS open_acc,
  CAST(pub_rec AS INTEGER) AS pub_rec,

  CAST(revol_bal AS REAL) AS revol_bal,
  CAST(REPLACE(revol_util, '%', '') AS REAL) AS revol_util_pct,
  CAST(total_acc AS INTEGER) AS total_acc,

  initial_list_status,

  CAST(out_prncp AS REAL) AS out_prncp,
  CAST(out_prncp_inv AS REAL) AS out_prncp_inv,

  CAST(total_pymnt AS REAL) AS total_pymnt,
  CAST(total_pymnt_inv AS REAL) AS total_pymnt_inv,

  CAST(total_rec_prncp AS REAL) AS total_rec_prncp,
  CAST(total_rec_int AS REAL) AS total_rec_int,
  CAST(total_rec_late_fee AS REAL) AS total_rec_late_fee,

  CAST(recoveries AS REAL) AS recoveries,
  CAST(collection_recovery_fee AS REAL) AS collection_recovery_fee,

  last_pymnt_d,
  CAST(last_pymnt_amnt AS REAL) AS last_pymnt_amnt,

  loan_status,

  CASE
    WHEN loan_status IN ('Charged Off', 'Default') THEN 1
    WHEN loan_status = 'Fully Paid' THEN 0
    ELSE NULL
  END AS default_flag
FROM raw_loans
WHERE loan_status IN ('Charged Off', 'Default', 'Fully Paid');

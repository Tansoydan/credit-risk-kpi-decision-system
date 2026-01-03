DROP TABLE IF EXISTS raw_loans;

CREATE TABLE raw_loans (
  row_id INTEGER PRIMARY KEY AUTOINCREMENT,

  id TEXT,
  member_id TEXT,

  loan_amnt TEXT,
  funded_amnt TEXT,
  funded_amnt_inv TEXT,

  term TEXT,
  int_rate TEXT,
  installment TEXT,

  grade TEXT,
  sub_grade TEXT,

  emp_title TEXT,
  emp_length TEXT,
  home_ownership TEXT,

  annual_inc TEXT,
  verification_status TEXT,

  issue_d TEXT,
  loan_status TEXT,

  purpose TEXT,
  title TEXT,
  zip_code TEXT,
  addr_state TEXT,

  dti TEXT,
  delinq_2yrs TEXT,

  earliest_cr_line TEXT,
  fico_range_low TEXT,
  fico_range_high TEXT,

  inq_last_6mths TEXT,
  open_acc TEXT,
  pub_rec TEXT,

  revol_bal TEXT,
  revol_util TEXT,
  total_acc TEXT,

  initial_list_status TEXT,

  out_prncp TEXT,
  out_prncp_inv TEXT,

  total_pymnt TEXT,
  total_pymnt_inv TEXT,

  total_rec_prncp TEXT,
  total_rec_int TEXT,
  total_rec_late_fee TEXT,

  recoveries TEXT,
  collection_recovery_fee TEXT,

  last_pymnt_d TEXT,
  last_pymnt_amnt TEXT,
  next_pymnt_d TEXT
);

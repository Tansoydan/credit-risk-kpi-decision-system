# Credit Risk & KPI Decision System

An end-to-end credit analytics project that transforms raw loan-level data into **credit approval decisions** using SQL-based KPIs, probabilistic risk modelling, and portfolio simulation.

The project mirrors how a real credit risk or analytics team would work:
- start with raw data ingestion and governance,
- build robust KPI views,
- train a leakage-safe Probability of Default (PD) model,
- translate PDs into approval policies and portfolio trade-offs.

---

## Workflow Overview

### 1) Data inspection (`01_data_inspection.ipynb`)
- Inspect schema, missingness, and data quality
- Validate date ranges and string-encoded numeric fields
- Identify columns suitable for modelling vs reporting

---

### 2) SQL staging & cleaning (`02_sql_staging_and_cleaning.ipynb`)
- Chunk-load raw CSV into SQLite (`raw_loans`)
- Create a typed, engineered table (`clean_loans`)
- Key transformations:
  - `term` → `term_months`
  - `emp_length` → `emp_length_yrs`
  - month strings (e.g. `Dec-2018`) → ISO dates (`YYYY-MM-01`)
  - `fico_avg` derived from FICO ranges
- Indexing added for fast KPI queries

---

### 3) KPI layer (`03_kpi_credit_risk.ipynb`)
Defines governance-ready credit KPIs:
- Portfolio volume, exposure, average rate & term
- Default (bad) rate by **grade** and **sub-grade**
- Vintage (issue-year) performance
- Rule-based approval policies (A–B, A–C, A–D)

**Default definition (realised outcomes only):**
- Bad/default: `Charged Off`, `Default`
- Good: `Fully Paid`
- Excluded: `Current`, `Late`, `In Grace Period`

KPI tables are exported to `data/kpi/` for BI use.

---

### 4) PD modelling (`04_pd_modelling.ipynb`)
Builds a leakage-safe **Probability of Default** model.

**Model**
- Logistic Regression (interpretable baseline)
- Median imputation (numeric)
- Most-frequent + one-hot encoding (categorical)

**Key modelling choices**
- Application-time features only (no leakage)
- Time-based train/test split (earlier vs later vintages)

**Performance (example run)**
- Test ROC-AUC ≈ 0.70  
- Test Brier score ≈ 0.16  
- Calibration curve close to diagonal with mild high-risk drift

PD scores are written back to SQLite in:


---

### 5) PD-based policy simulation (`05_pd_policy_simulation.ipynb`)
Turns PDs into **approval decisions** and compares:
- PD-threshold policies (e.g. PD < 10%, 15%, 20%)
vs
- Grade-based rules (A–B, A–C, A–D)

Reported on the **out-of-sample test set**:
- approval rate
- realised default rate among approved loans
- expected defaults (sum of PD)
- expected loss proxy using a simple LGD assumption

Simulation outputs are exported to `data/simulation/`.

---

## Key Insights

- Default rates increase monotonically from grade A → G, validating underwriting logic
- PD-based thresholds provide a smoother risk–approval trade-off than grade cut-offs
- A balanced PD policy increases approval volume with a controlled rise in default risk
- Separating **risk estimation (PD)** from **decision rules** improves transparency and control

---

## How to Run

### Requirements
- Python 3.10+
- pandas, numpy, scikit-learn, matplotlib
- sqlite3 (built-in)

# Executive Summary 

## Objective
The objective of this project was to build a data-driven credit decision framework that moves beyond coarse grade-based approval rules and enables explicit control of portfolio risk through loan-level Probability of Default (PD) estimates.

The system was designed to reflect a realistic credit analytics workflow: robust SQL-based data staging and KPI reporting, leakage-safe PD modelling, and policy simulation to quantify the trade-offs between growth and risk.

---

## Data & Scope
- ~1.35 million historical consumer loans
- Issue dates spanning 2007–2018
- Analysis restricted to loans with **observed outcomes** only
- Default defined as: `Charged Off` or `Default`
- Ongoing loans (`Current`, `Late`, `In Grace Period`) excluded from modelling

All PD modelling uses **application-time features only**, ensuring no post-origination leakage.

---

## Key Findings

### Portfolio Risk Characteristics
- Default rates increase monotonically from grade A to G, confirming that grades broadly capture risk but hide substantial within-grade variation.
- Later vintages (post-2016) exhibit materially higher default rates, reinforcing the need for time-aware validation.

### PD Model Performance
- A baseline logistic regression PD model achieves:
  - Test ROC-AUC ≈ **0.70**
  - Test Brier score ≈ **0.16**
- Calibration is stable across most of the PD range, with mild under-prediction in the highest-risk tail.
- The model generalises well under a time-based train/test split, indicating robustness to portfolio drift.

---

## Policy Simulation Results (Test Set)

PD-based approval thresholds were compared against traditional grade cut-offs on the same out-of-sample population.

### Conservative Policies  
- **PD < 10%** approves **25%** of applicants with a realised default rate of **8.2%**
- **Grade A–B** approves **46%** of applicants with a realised default rate of **12.3%**

Despite approving fewer loans, the PD-based policy materially reduces default and expected loss, demonstrating that grade-based rules labelled “conservative” can still embed significant hidden risk.

---

### Balanced Policies  
- **PD < 15%** approves **49%** of applicants with a realised default rate of **12.5%**
- **Grade A–C** approves **76%** of applicants with a realised default rate of **17.5%**

At comparable portfolio exposure levels, PD-based decisioning delivers substantially better risk control, placing it on a superior risk–reward frontier.

---

### Growth Policies  
- **PD < 20%** approves **66%** of applicants with a realised default rate of **15.4%**
- **Grade A–D** approves **91%** of applicants with a realised default rate of **20.2%**

Grade-based growth policies effectively become risk-blind, whereas PD thresholds allow controlled expansion with predictable increases in loss.

---

## Core Insight
Grade-based approval rules are blunt instruments that pool heterogeneous risk within discrete buckets. PD-based thresholds provide continuous, transparent control of portfolio risk and allow approval volumes to be adjusted without unintentionally exceeding risk appetite.

---

## Recommendation
Adopt PD-based approval thresholds as the primary credit decision mechanism, with thresholds adjusted according to business objectives:

- **Conservative:** PD < 10% (capital preservation)
- **Balanced:** PD < 15% (steady-state growth)
- **Growth:** PD < 20% (controlled expansion)

This framework improves capital efficiency, enhances risk transparency, and enables deliberate, data-driven policy decisions.

---

## Limitations & Next Steps
- LGD is treated as constant in this version; future work should introduce segmented LGD/EAD assumptions.
- PDs are suitable for decision support but not calibrated to regulatory standards.
- Extensions could include profit simulation, PD recalibration, and non-linear models for comparison.

---

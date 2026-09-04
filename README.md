[README.md](https://github.com/user-attachments/files/31847938/README.md)
# Insurance Collections & Operations Analysis

SQL, Excel and Power BI-ready portfolio project analysing premium collection performance across a synthetic insurance portfolio.

> This project uses 100% synthetic data. It contains no real customer, policy or company information.

![Dashboard Preview](assets/dashboard-preview.png)

## Business Problem

An insurance operations team needs a repeatable view of written premium, collected premium, outstanding receivables and late-payment behaviour. The analysis is designed to answer:

- What is the overall collection rate and outstanding exposure?
- Which products and channels perform best or require intervention?
- How does collection performance change by month?
- How are overdue balances distributed across aging buckets?
- Which overdue policies should be prioritised operationally?

## Dataset

- 1,200 synthetic policy records
- Period: January-December 2025
- Products: Motor Own Damage, Compulsory Traffic, Home, Health and Travel
- Channels: Agency, Digital, Bank and Call Centre
- Dimensions: product, channel, region, customer segment, agent and risk score
- Measures: premium, collected amount, outstanding amount, days late and renewal indicator

The Turkish product labels used in the dataset are retained to reflect a local insurance use case.

## Core KPIs

| KPI | Result |
|---|---:|
| Written premium | TRY 22,010,300 |
| Collected premium | TRY 19,374,000 |
| Collection rate | 88.02% |
| Outstanding receivables | TRY 2,636,300 |
| Overdue policies | 132 |
| Average late-payment delay | 14.45 days |

## Key Findings

1. **Digital is the strongest collection channel** with a 90.80% collection rate.
2. **Bank is the weakest channel** at 81.48%, indicating a need to review reminders, reconciliation timing or integration exceptions.
3. **Home insurance has the highest product collection rate** at 91.50%.
4. **Motor own damage has the lowest product collection rate** at 85.55% and represents a meaningful improvement opportunity due to its high premium volume.
5. Overdue exposure is distributed across all aging groups, including TRY 390,390 in the 90+ day bucket. A prioritised follow-up list is therefore more useful than a single overdue total.

## Recommended Actions

- Investigate failed or delayed reconciliation steps in the Bank channel.
- Apply targeted reminders before due date for high-risk motor policies.
- Route high-value 61+ day receivables to a dedicated collection queue.
- Monitor collection rate and outstanding exposure by month, product and channel.
- Add reason codes for overdue and cancellation events in a production implementation.

## Repository Structure

```text
insurance-collections-analytics/
├── README.md
├── analysis_summary.json
├── data/
│   ├── insurance_collections_2025.csv
│   └── insurance_collections.db
├── sql/
│   ├── analysis.sql
│   └── load_and_validate.py
└── assets/
    └── dashboard-preview.png
```

The Excel dashboard is delivered separately as `Insurance_Collections_KPI_Analysis_2025.xlsx` and contains:

- Executive dashboard with eight KPI cards
- Monthly premium and collection analysis
- Product and channel performance charts
- Open-receivable aging chart
- 1,200-row analysis-ready dataset
- Data dictionary and KPI definitions

## SQL Analysis

`sql/analysis.sql` includes:

- Executive KPI summary
- Monthly trend analysis
- Product and channel performance
- Receivable aging
- Risk-band and renewal analysis
- Operational priority list for overdue policies

To create and validate the local SQLite database:

```bash
python sql/load_and_validate.py
```

## Power BI Data Model

Import `data/insurance_collections_2025.csv` and use the following measures:

```DAX
Total Premium = SUM(insurance_collections_2025[Premium_TRY])

Total Collected = SUM(insurance_collections_2025[Collected_TRY])

Outstanding Amount = SUM(insurance_collections_2025[Outstanding_TRY])

Collection Rate = DIVIDE([Total Collected], [Total Premium], 0)

Overdue Policies =
CALCULATE(
    COUNTROWS(insurance_collections_2025),
    insurance_collections_2025[Payment_Status] = "Overdue"
)
```

## Skills Demonstrated

SQL • KPI Design • Business Analysis • Data Quality • Excel Dashboarding • Power BI-ready Modelling • Receivables Aging • Operational Recommendations


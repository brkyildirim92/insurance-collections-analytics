-- Insurance Collections KPI Analysis (SQLite)
-- Dataset: data/insurance_collections_2025.csv
-- All records are synthetic and created solely for portfolio use.

DROP TABLE IF EXISTS insurance_collections;

CREATE TABLE insurance_collections (
    policy_id TEXT PRIMARY KEY,
    customer_segment TEXT NOT NULL,
    product TEXT NOT NULL,
    channel TEXT NOT NULL,
    region TEXT NOT NULL,
    issue_date TEXT NOT NULL,
    due_date TEXT NOT NULL,
    payment_date TEXT,
    month TEXT NOT NULL,
    premium_try REAL NOT NULL,
    collected_try REAL NOT NULL,
    outstanding_try REAL NOT NULL,
    payment_status TEXT NOT NULL,
    days_late INTEGER NOT NULL,
    aging_bucket TEXT NOT NULL,
    currency TEXT NOT NULL,
    agent_id TEXT NOT NULL,
    risk_score INTEGER NOT NULL,
    renewal_flag TEXT NOT NULL
);

-- Q1: Executive KPI summary
SELECT
    COUNT(*) AS policy_count,
    ROUND(SUM(premium_try), 2) AS total_premium_try,
    ROUND(SUM(collected_try), 2) AS total_collected_try,
    ROUND(SUM(outstanding_try), 2) AS outstanding_try,
    ROUND(SUM(collected_try) / NULLIF(SUM(premium_try), 0) * 100, 2) AS collection_rate_pct,
    SUM(CASE WHEN payment_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_policy_count,
    ROUND(AVG(CASE WHEN payment_status = 'Paid Late' THEN days_late END), 2) AS avg_late_payment_days
FROM insurance_collections;

-- Q2: Monthly premium and collection trend
SELECT
    month,
    COUNT(*) AS policy_count,
    ROUND(SUM(premium_try), 2) AS premium_try,
    ROUND(SUM(collected_try), 2) AS collected_try,
    ROUND(SUM(outstanding_try), 2) AS outstanding_try,
    ROUND(SUM(collected_try) / NULLIF(SUM(premium_try), 0) * 100, 2) AS collection_rate_pct
FROM insurance_collections
GROUP BY month
ORDER BY month;

-- Q3: Product performance
SELECT
    product,
    COUNT(*) AS policy_count,
    ROUND(SUM(premium_try), 2) AS premium_try,
    ROUND(SUM(collected_try), 2) AS collected_try,
    ROUND(SUM(collected_try) / NULLIF(SUM(premium_try), 0) * 100, 2) AS collection_rate_pct,
    ROUND(SUM(outstanding_try), 2) AS outstanding_try
FROM insurance_collections
GROUP BY product
ORDER BY collection_rate_pct DESC;

-- Q4: Channel performance and overdue exposure
SELECT
    channel,
    COUNT(*) AS policy_count,
    ROUND(SUM(collected_try) / NULLIF(SUM(premium_try), 0) * 100, 2) AS collection_rate_pct,
    SUM(CASE WHEN payment_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_count,
    ROUND(SUM(CASE WHEN payment_status = 'Overdue' THEN outstanding_try ELSE 0 END), 2) AS overdue_outstanding_try
FROM insurance_collections
GROUP BY channel
ORDER BY collection_rate_pct DESC;

-- Q5: Open-receivable aging
SELECT
    aging_bucket,
    COUNT(*) AS policy_count,
    ROUND(SUM(outstanding_try), 2) AS outstanding_try,
    ROUND(SUM(outstanding_try) /
          NULLIF((SELECT SUM(outstanding_try) FROM insurance_collections WHERE payment_status = 'Overdue'), 0)
          * 100, 2) AS share_of_overdue_pct
FROM insurance_collections
WHERE payment_status = 'Overdue'
GROUP BY aging_bucket
ORDER BY CASE aging_bucket
    WHEN '1-30 Days' THEN 1
    WHEN '31-60 Days' THEN 2
    WHEN '61-90 Days' THEN 3
    WHEN '90+ Days' THEN 4
END;

-- Q6: Risk-score bands and payment behaviour
WITH risk_bands AS (
    SELECT *,
        CASE
            WHEN risk_score < 40 THEN 'Low'
            WHEN risk_score < 65 THEN 'Medium'
            ELSE 'High'
        END AS risk_band
    FROM insurance_collections
)
SELECT
    risk_band,
    COUNT(*) AS policy_count,
    ROUND(AVG(risk_score), 1) AS avg_risk_score,
    ROUND(SUM(collected_try) / NULLIF(SUM(premium_try), 0) * 100, 2) AS collection_rate_pct,
    ROUND(AVG(CASE WHEN renewal_flag = 'Yes' THEN 1.0 ELSE 0.0 END) * 100, 2) AS renewal_rate_pct
FROM risk_bands
GROUP BY risk_band
ORDER BY CASE risk_band WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- Q7: Operational priority list (top 25 overdue policies)
SELECT
    policy_id,
    customer_segment,
    product,
    channel,
    region,
    due_date,
    days_late,
    aging_bucket,
    outstanding_try,
    risk_score
FROM insurance_collections
WHERE payment_status = 'Overdue'
ORDER BY outstanding_try DESC, days_late DESC
LIMIT 25;

CREATE VIEW vw_campaign_funnel AS
SELECT
    'Campaign 1' AS campaign_stage, SUM(acceptedcmp1) AS accepted_count, COUNT(*) AS total_customers, ROUND(100.0 * SUM(acceptedcmp1) / COUNT(*), 2) AS acceptance_rate_pct
FROM fact_customers
UNION ALL
SELECT 'Campaign 2', SUM(acceptedcmp2), COUNT(*), ROUND(100.0 * SUM(acceptedcmp2) / COUNT(*), 2) FROM fact_customers
UNION ALL
SELECT 'Campaign 3', SUM(acceptedcmp3), COUNT(*), ROUND(100.0 * SUM(acceptedcmp3) / COUNT(*), 2) FROM fact_customers
UNION ALL
SELECT 'Campaign 4', SUM(acceptedcmp4), COUNT(*), ROUND(100.0 * SUM(acceptedcmp4) / COUNT(*), 2) FROM fact_customers
UNION ALL
SELECT 'Campaign 5', SUM(acceptedcmp5), COUNT(*), ROUND(100.0 * SUM(acceptedcmp5) / COUNT(*), 2) FROM fact_customers
UNION ALL
SELECT 'Final Response', SUM(response), COUNT(*), ROUND(100.0 * SUM(response) / COUNT(*), 2) FROM fact_customers;

CREATE VIEW vw_segment_performance AS
SELECT
    age_group,
    income_bracket,
    COUNT(*) AS total_customers,
    SUM(response) AS responders,
    ROUND(100.0 * SUM(response) / COUNT(*), 2) AS response_rate_pct,
    ROUND(AVG(total_spend), 0) AS avg_spend
FROM fact_customers
GROUP BY age_group, income_bracket
ORDER BY response_rate_pct DESC;

CREATE VIEW vw_segment_performance_reliable AS
SELECT *
FROM vw_segment_performance
WHERE total_customers >= 30
ORDER BY response_rate_pct DESC;

CREATE VIEW vw_channel_effectiveness AS
SELECT
    response,
    ROUND(AVG(numwebpurchases), 2) AS avg_web_purchases,
    ROUND(AVG(numcatalogpurchases), 2) AS avg_catalog_purchases,
    ROUND(AVG(numstorepurchases), 2) AS avg_store_purchases,
    ROUND(AVG(numdealspurchases), 2) AS avg_deal_purchases
FROM fact_customers
GROUP BY response;

CREATE VIEW vw_spend_by_category AS
SELECT 'Wine' AS category, SUM(mntwines) AS total_spend FROM fact_customers
UNION ALL
SELECT 'Meat', SUM(mntmeatproducts) FROM fact_customers
UNION ALL
SELECT 'Gold', SUM(mntgoldprods) FROM fact_customers
UNION ALL
SELECT 'Fish', SUM(mntfishproducts) FROM fact_customers
UNION ALL
SELECT 'Sweets', SUM(mntsweetproducts) FROM fact_customers
UNION ALL
SELECT 'Fruits', SUM(mntfruits) FROM fact_customers
ORDER BY total_spend DESC;

CREATE VIEW vw_top_segments AS
SELECT * FROM vw_segment_performance_reliable ORDER BY response_rate_pct DESC LIMIT 5;

CREATE VIEW vw_bottom_segments AS
SELECT * FROM vw_segment_performance_reliable ORDER BY response_rate_pct ASC LIMIT 5;

CREATE VIEW vw_response_by_education_marital AS
SELECT
    education,
    marital_status,
    COUNT(*) AS total_customers,
    SUM(response) AS responders,
    ROUND(100.0 * SUM(response) / COUNT(*), 2) AS response_rate_pct
FROM fact_customers
GROUP BY education, marital_status
HAVING COUNT(*) >= 20
ORDER BY response_rate_pct DESC;

CREATE VIEW vw_recency_analysis AS
SELECT
    CASE
        WHEN recency <= 20 THEN '0-20 days'
        WHEN recency <= 40 THEN '21-40 days'
        WHEN recency <= 60 THEN '41-60 days'
        WHEN recency <= 80 THEN '61-80 days'
        ELSE '80+ days'
    END AS recency_band,
    COUNT(*) AS total_customers,
    SUM(response) AS responders,
    ROUND(100.0 * SUM(response) / COUNT(*), 2) AS response_rate_pct
FROM fact_customers
GROUP BY recency_band
ORDER BY MIN(recency);

CREATE VIEW vw_complaint_impact AS
SELECT
    complain,
    COUNT(*) AS total_customers,
    SUM(response) AS responders,
    ROUND(100.0 * SUM(response) / COUNT(*), 2) AS response_rate_pct
FROM fact_customers
GROUP BY complain;


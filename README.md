# Marketing Campaign Performance Dashboard

Which customer segments and channels drive the highest campaign response, and where is marketing spend being wasted?

## The question

A retailer ran five marketing campaign waves plus a final response measure, but had no clear read on which customers were worth targeting, which channel mattered most, or whether any campaign wave underperformed. This project evaluates campaign response rates and customer segments to guide future targeting.

## Data source

**Dataset:** Marketing Campaign (customer demographics, spend, and campaign response)
**Source:** Kaggle (kaggle.com/datasets/rodsaldanha/arketing-campaign)
**Size:** 2,240 customers, reduced to 2,216 after removing rows with missing income.

## Pipeline

```
Raw Kaggle CSV (semicolon-delimited, 29 columns)
        |
        v
Python (pandas): drop missing income, engineer 6 new features
        |
        v
SQLite (fact_customers)
        |
        v
SQL views (UNION ALL funnel, segmentation with sample-size filtering, channel comparison)
        |
        v
Power BI two-page dashboard
```

**1. Python** (`python/prepare_marketing_data.py`)
Drops rows with missing income (a known data quality issue in this dataset), then engineers six new features not present in the raw file: age, total spend across all product categories, total campaigns accepted, customer tenure in days, family size, and binned income/age groups.

**2. SQL schema** (`sql/create_tables.sql`)
Single fact table, `fact_customers`, holding all raw and derived fields.

**3. Analysis views** (`sql/analysis_views.sql`)
- `vw_campaign_funnel` — stacks all five campaign acceptance flags plus the final response flag into one funnel-ready table using UNION ALL
- `vw_segment_performance` / `vw_segment_performance_reliable` — response rate by age group and income bracket, with a minimum sample size filter (30+ customers) to avoid reporting misleading small-sample results
- `vw_channel_effectiveness` — average purchases by channel (web, catalog, store, deals), compared between responders and non-responders
- `vw_spend_by_category` — total spend across six product categories
- `vw_response_by_education_marital` — response rate by education level and marital status
- `vw_recency_analysis` — response rate binned by days since last purchase
- `vw_complaint_impact` — response rate compared between customers who have and haven't filed a complaint

**4. Power BI dashboard**
Two pages: "Campaign Overview & Funnel" (KPIs, funnel visual, spend by category, recency trend) and "Segment & Channel Deep-Dive" (top/bottom performing segments, channel comparison, education/marital breakdown).

## Key findings

- **Response rate drops sharply and consistently with recency**: customers who purchased in the last 20 days respond at 28.75%, falling monotonically to 6.33% for those inactive 80+ days — a 4.5x difference with no reversals across any band. This is the strongest, cleanest signal in the entire dataset.
- **Campaign 2 significantly underperformed every other wave**, at just 1.35% acceptance versus 6.4-7.4% for Campaigns 1, 3, 4, and 5 — roughly a 5x gap worth investigating (offer type, timing, or targeting likely differed).
- **The 40s age group with High income is the most reliable high-value segment**, responding at 25.62% (vs. an overall baseline of 15.03%) across a sample of 121 customers. A smaller segment (30s, Very High income) showed a higher raw rate but was excluded from headline reporting due to a sample size of only 9 customers, which would be unreliable to act on.
- **Wine dominates category spend**, accounting for roughly $676K, nearly double the next-highest category (Meat, $370K) and far ahead of all others.
- **Responders show notably higher catalog and web purchase activity** than non-responders, while store and deal-driven purchases show little difference — suggesting catalog engagement in particular is a meaningful behavioral signal for targeting.
- **PhD-educated customers consistently outperform other education levels** across marital statuses (Divorced PhDs: 34.62%, Single PhDs: 31.25%), a distinct pattern from income/age alone.
- **Past complaints showed no meaningful effect on future response** (15.03% vs. 14.29%, with only 21 customers in the complaint group) — reported honestly as a non-finding rather than stretched into a false pattern.

## Methodology note

Segment-level findings are reported only where the underlying sample size is large enough to be reasonably trustworthy (30+ customers for demographic segments). Smaller segments with striking headline numbers were deliberately excluded from top-line reporting, since a handful of customers can produce misleadingly extreme percentages. This tradeoff is intentional: a slightly less dramatic but statistically defensible finding is more useful for an actual targeting decision than a flashy but fragile one.

## Tools used

Python (pandas) - SQLite - SQL (UNION ALL, aggregation, filtering) - Power BI (funnel visuals, DAX measures, two-page dashboard design)

## Folder structure

```
marketing-campaign-dashboard/
|-- data/
|   |-- raw/          <- download the Kaggle dataset here (not committed)
|   |-- staging/       <- cleaned/engineered CSV after Python processing
|   `-- processed/     <- SQLite database file
|-- sql/
|   |-- create_tables.sql
|   `-- analysis_views.sql
|-- python/
|   `-- prepare_marketing_data.py
|-- powerbi/
|   `-- marketing_campaign_dashboard.pbix
|-- docs/
`-- README.md
```
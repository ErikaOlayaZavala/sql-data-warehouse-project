-- ============================================================
-- ADD COLUMN DESCRIPTIONS · analytics.master_customer
-- Project : analytical-engineer-project
--
-- Uses ALTER TABLE ... ALTER COLUMN SET OPTIONS so the data
-- is never touched — only the metadata is updated.
-- Run this once after the master_customer table has been created.
-- Descriptions appear immediately in the BigQuery UI,
-- Looker Studio, and INFORMATION_SCHEMA.COLUMNS.
-- ============================================================

-- Table-level description
ALTER TABLE `analytical-engineer-project.analytics.master_customer`
SET OPTIONS (
  description = 'Customer-grain analytical table. One row per user_uuid. Aggregates the event-level analytics.orders table into identity, cohort, activity, financial, and retention columns. Use as the foundation for retention curves, cohort analysis, platform strategy, and profitability analysis. Reactivation definition: any order where the gap since the previous order exceeds 365 days.'
);

-- Column descriptions (all 21 columns)
ALTER TABLE `analytical-engineer-project.analytics.master_customer`

  -- ── 1. Identity ──────────────────────────────────────────────
  ALTER COLUMN user_uuid
    SET OPTIONS (description = 'Anonymised, stable customer identifier. Primary key of this table — one row per user_uuid.'),

  ALTER COLUMN customer_city
    SET OPTIONS (description = 'Most recent non-null city from the customer billing or registration address. Standardised to title-case.'),

  ALTER COLUMN customer_country
    SET OPTIONS (description = 'Most recent non-null ISO-2 country code (e.g. US, GB, DE). Backfilled from same-user history where originally null.'),

  ALTER COLUMN primary_platform
    SET OPTIONS (description = 'Platform used most frequently by the customer across all their orders. Values: app, web, touch.'),

  -- ── 2. Cohort & lifecycle ─────────────────────────────────────
  ALTER COLUMN first_order_date
    SET OPTIONS (description = 'Date of the customers very first order. Use to assign cohort membership and calculate customer age.'),

  ALTER COLUMN cohort_month
    SET OPTIONS (description = 'Month of the customers first order, truncated to the 1st of the month. Use as the cohort key for month-over-month retention analysis.'),

  ALTER COLUMN last_order_date
    SET OPTIONS (description = 'Date of the customers most recent order. Use together with days_since_last_order to identify churn risk.'),

  ALTER COLUMN days_since_last_order
    SET OPTIONS (description = 'Number of days between the customers last order and today (CURRENT_DATE). Recalculated each time the table is refreshed.'),

  -- ── 3. Activity ───────────────────────────────────────────────
  ALTER COLUMN total_orders
    SET OPTIONS (description = 'Total number of order lines placed by the customer across the full history, including refunded orders.'),

  ALTER COLUMN total_sessions
    SET OPTIONS (description = 'Total number of distinct checkout sessions (distinct parent_order_uuid values). One session can contain multiple order lines.'),

  ALTER COLUMN first_platform
    SET OPTIONS (description = 'Platform used on the customers very first order. Represents the acquisition channel. Values: app, web, touch.'),

  ALTER COLUMN is_multi_platform
    SET OPTIONS (description = 'TRUE if the customer has placed orders on more than one platform. Useful for cross-platform behaviour analysis.'),

  -- ── 4. Financials (USD) ───────────────────────────────────────
  ALTER COLUMN gross_bookings_usd
    SET OPTIONS (description = 'Total gross bookings in USD across all orders, including refunds (which are negative). Primary top-line revenue metric. Converted using fx_rate_loc_to_usd_fxn.'),

  ALTER COLUMN margin_1_usd
    SET OPTIONS (description = 'Total margin_1 in USD. Gross revenue minus direct variable costs after merchant payments. Negative contributions from refunded orders are included.'),

  ALTER COLUMN vfm_usd
    SET OPTIONS (description = 'Total VFM (value for money) in USD. Net economics metric on the merchant side. Subset of margin_1_usd. Negative contributions from refunded orders are included.'),

  ALTER COLUMN avg_order_value_usd
    SET OPTIONS (description = 'Average gross bookings per order in USD, excluding refunded orders. Use to compare spend per transaction across segments or platforms.'),

  ALTER COLUMN promo_usage_rate
    SET OPTIONS (description = 'Share of non-refunded orders where a promo code was applied. Value between 0 and 1. Example: 0.25 = 25% of orders used a promo code.'),

  -- ── 5. Retention signals ──────────────────────────────────────
  ALTER COLUMN total_refunds
    SET OPTIONS (description = 'Total number of orders with last_status = refunded. Use as a customer quality signal.'),

  ALTER COLUMN refund_rate
    SET OPTIONS (description = 'Share of total orders that were refunded. Value between 0 and 1. Example: 0.10 = 10% refund rate.'),

  ALTER COLUMN total_reactivations
    SET OPTIONS (description = 'Number of times the customer returned after a gap of more than 365 days since their previous order. 0 for customers who have never lapsed.'),

  ALTER COLUMN is_active_last_12m
    SET OPTIONS (description = 'TRUE if the customer placed at least one order in the last 365 days. Recalculated each time the table is refreshed.'),

  ALTER COLUMN customer_segment
    SET OPTIONS (description = 'Mutually exclusive customer segment based on recency and reactivation history. Values: new (first order within last 90 days), churned (last order > 365 days ago), reactivated (returned after >365 day gap, active within last 365 days), regular (active within last 365 days, no reactivation history).')
;

-- ------------------------------------------------------------
-- VERIFY — check descriptions were applied correctly
-- ------------------------------------------------------------
SELECT
  column_name,
  description
FROM `analytical-engineer-project.analytics.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS`
WHERE table_name = 'master_customer'
ORDER BY 1
;

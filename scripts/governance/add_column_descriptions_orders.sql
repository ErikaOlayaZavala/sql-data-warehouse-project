-- ============================================================
-- ADD COLUMN DESCRIPTIONS · analytics.orders
-- Project : analytical-engineer-project
--
-- Uses ALTER TABLE ... ALTER COLUMN SET OPTIONS so the data
-- is never touched — only the metadata is updated.
-- Run this once. Descriptions appear immediately in the
-- BigQuery UI, Looker Studio, and INFORMATION_SCHEMA.COLUMNS.
-- ============================================================

-- Table-level description
ALTER TABLE `analytical-engineer-project.analytics.orders`
SET OPTIONS (
  description = 'Clean, deduplicated order-level transaction table covering Jan 2021 to Feb 2025. One row per order_uuid. Financial columns are in local currency — multiply by fx_rate_loc_to_usd_fxn to convert to USD. Use as the foundation for all revenue, retention, and platform analysis.'
);

-- Column descriptions
ALTER TABLE `analytical-engineer-project.analytics.orders`
  ALTER COLUMN operational_view_date
    SET OPTIONS (description = 'Transaction date from an operational perspective. Primary date field for all time-based analysis.'),
  ALTER COLUMN user_uuid
    SET OPTIONS (description = 'Anonymised, stable customer identifier. Consistent across sessions and platforms. Use as the customer key for joins and aggregations.'),
  ALTER COLUMN customer_city
    SET OPTIONS (description = 'City from the customer billing or registration address. Standardised to title-case (e.g. New York).'),
  ALTER COLUMN customer_country
    SET OPTIONS (description = 'ISO-2 country code of the customer (e.g. US, GB, DE). Backfilled where originally null using same-user history and city lookup.'),
  ALTER COLUMN order_uuid
    SET OPTIONS (description = 'Unique identifier for an individual order line. One checkout session can produce multiple order_uuid values. Deduplicated: each value appears exactly once in this table.'),
  ALTER COLUMN parent_order_uuid
    SET OPTIONS (description = 'Groups all order lines from the same checkout session. Equals order_uuid when a single item was purchased. Multiple order lines sharing a parent_order_uuid were bought together.'),
  ALTER COLUMN platform
    SET OPTIONS (description = 'Sales channel where the purchase was made. Standardised to lowercase. Allowed values: app (mobile application), web (desktop or mobile browser), touch (tablet-optimised web).'),
  ALTER COLUMN fx_rate_loc_to_usd_fxn
    SET OPTIONS (description = 'Exchange rate to convert local currency to USD. Multiply any _operational column by this rate. Example: gross_bookings_usd = gross_bookings_operational * fx_rate_loc_to_usd_fxn.'),
  ALTER COLUMN list_price_operational
    SET OPTIONS (description = 'Original deal price before any discounts, in local currency. Always >= 0. Formula: gross_bookings = list_price_operational - deal_discount_operational.'),
  ALTER COLUMN deal_discount_operational
    SET OPTIONS (description = 'Discount amount applied to the order in local currency. Always >= 0 and never exceeds list_price_operational on non-refunded orders.'),
  ALTER COLUMN gross_bookings_operational
    SET OPTIONS (description = 'Amount actually paid by the customer, in local currency. Primary top-line revenue metric. Negative values indicate a refund.'),
  ALTER COLUMN margin_1_operational
    SET OPTIONS (description = 'Gross revenue minus direct variable costs, in local currency. First level of profitability after merchant payments. Negative on refund rows.'),
  ALTER COLUMN vfm_operational
    SET OPTIONS (description = 'Net economics metric capturing deal-level profitability on the merchant side, in local currency. Subset of margin_1_operational. Negative on refund rows.'),
  ALTER COLUMN incentive_promo_code
    SET OPTIONS (description = 'Promo code applied to the order. Null when no promo was used.'),
  ALTER COLUMN last_status
    SET OPTIONS (description = 'Final recorded order status. Values: redeemed (voucher used), unredeemed (purchased but not yet used), refunded (order reversed — all financial columns are negative), expired (voucher passed validity window unused).'),
  ALTER COLUMN source_file
    SET OPTIONS (description = 'Lineage tag identifying the source file. Values: historical (Jan 2021–Jun 2023), 2024_2025 (Jul 2023–Feb 2025).')
;

-- ------------------------------------------------------------
-- VERIFY — check descriptions were applied correctly
-- ------------------------------------------------------------
SELECT
  column_name,
  description
FROM `analytical-engineer-project.analytics.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS`
WHERE table_name = 'orders'
;

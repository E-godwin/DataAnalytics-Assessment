-- Q3: Account Inactivity Alert
-- Goal: Find all active accounts (savings or investments) with no inflow transactions in the last 1 year (365 days)

WITH latest_txn AS (
    SELECT
        sa.plan_id,
        MAX(sa.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount sa
    -- Optional: Only count successful inflow transactions (you may uncomment the line below if needed)
    -- WHERE sa.transaction_status = 'successful'
    GROUP BY sa.plan_id
),

plan_type_classified AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        p.is_deleted,
        p.is_archived
    FROM plans_plan p
    WHERE p.is_deleted = 0 AND p.is_archived = 0 -- Only include active plans
),

plan_inactivity AS (
    SELECT
        ptc.plan_id,
        ptc.owner_id,
        ptc.type,
        lt.last_transaction_date,
        DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days
    FROM latest_txn lt
    JOIN plan_type_classified ptc ON lt.plan_id = ptc.plan_id
    WHERE DATEDIFF(CURDATE(), lt.last_transaction_date) > 365
)

SELECT * FROM plan_inactivity
ORDER BY inactivity_days DESC;
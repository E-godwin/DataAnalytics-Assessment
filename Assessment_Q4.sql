-- Q4: Customer Lifetime Value (CLV) Estimation
-- Goal: Estimate CLV using a simplified model based on:
-- - Number of months since signup (tenure)
-- - Number of transactions
-- - Profit per transaction = 0.1% of transaction value

WITH customer_transactions AS (
    SELECT
        sa.owner_id,
        -- Total confirmed inflow per customer
        SUM(sa.confirmed_amount) AS total_transaction_value,
        -- Count of total transactions
        COUNT(*) AS total_transactions
    FROM savings_savingsaccount sa
    -- I am including all transactions (optional: filter by status if needed)
    GROUP BY sa.owner_id
),

customer_tenure AS (
    SELECT
        u.id AS customer_id,
        u.name,
        -- Calculate how many months the customer has been active since signup
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months
    FROM users_customuser u
),

clv_calc AS (
    SELECT
        ct.owner_id AS customer_id,
        ut.name,
        ut.tenure_months,
        ct.total_transactions,
        
        -- Average profit per transaction = 0.1% of total confirmed inflows
        ROUND((ct.total_transaction_value / 1000), 2) AS total_profit,  -- since 0.1% = /1000

        -- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
        -- Note: I first calculate avg_profit_per_transaction = total_profit / total_transactions
        -- Then use the formula above
        ROUND(
            (
                (ct.total_transactions / NULLIF(ut.tenure_months, 0)) * 12
                * ( (ct.total_transaction_value / 1000) / NULLIF(ct.total_transactions, 0) )
            ), 
            2
        ) AS estimated_clv
    FROM customer_transactions ct
    JOIN customer_tenure ut ON ct.owner_id = ut.customer_id
)

-- Final result: List of customers ordered by highest CLV
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;

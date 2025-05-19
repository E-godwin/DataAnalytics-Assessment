-- Q2: Transaction Frequency Analysis
-- Objective: Categorize customers into "High", "Medium", or "Low" frequency
-- based on how often they make transactions every month on average.

-- Calculate total number of transactions per customer and how many months they've been active
WITH customer_monthly_txn AS (
    SELECT
        sa.owner_id,  -- customer ID
        COUNT(*) AS total_transactions,  -- total number of transactions done by this customer
        
        -- Calculate how many months they’ve been transacting (difference between earliest and latest transaction date)
        TIMESTAMPDIFF(MONTH, MIN(sa.transaction_date), MAX(sa.transaction_date)) + 1 AS active_months
        
        -- I added +1 to avoid dividing by zero, especially if transaction dates fall within the same month
    FROM savings_savingsaccount sa
    
    -- OPTIONAL: Uncomment this if business wants to track only successful transactions
    -- WHERE sa.transaction_status = 'successful'
    GROUP BY sa.owner_id
),

-- Calculate average number of transactions per customer per month
txn_summary AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 2) AS avg_txn_per_month  -- calculate monthly average
    FROM customer_monthly_txn
),

-- Categorize customers based on the average number of transactions per month
txn_category AS (
    SELECT
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'        -- if avg >= 10 transactions/month
            WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency' -- between 3 and 9
            ELSE 'Low Frequency'                                      -- 2 or fewer transactions/month
        END AS frequency_category,
        COUNT(*) AS customer_count,                                   -- number of customers in each category
        ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month -- average transaction count for that category
    FROM txn_summary
    GROUP BY frequency_category
)

-- Show results ordered properly: High first, then Medium, then Low
SELECT * FROM txn_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
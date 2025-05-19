-- Select key customer information and metrics for high-value users
SELECT 
    u.id AS owner_id,  -- Get the customer's unique ID (aliased as 'owner_id' to match expected output)
    u.name,            -- Get the customer's name from users_customuser

-- Count how many distinct savings plans (is_regular_savings = 1) the customer has
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,

-- Count how many distinct investment plans (is_a_fund = 1) the customer has
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,

-- Sum of all confirmed deposit amounts for the customer (in kobo → divide by 100 to convert to Naira)
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits

-- Start from the users table, which contains customer details
FROM users_customuser u

-- Join with the plans table to access the plans each customer owns
JOIN plans_plan p ON u.id = p.owner_id

-- Left join to savings_savingsaccount to include all savings data (even if some users have no deposits)
LEFT JOIN savings_savingsaccount s 
    ON s.owner_id = u.id         -- Making sure the savings entry belongs to the same user
    AND s.plan_id = p.id         -- Ensuring the transaction is linked to the user's specific plan
    AND s.confirmed_amount > 0   -- Only include savings that were actually deposited (funded)

-- Filtering out any plans that were deleted or archived leaving the active ones
WHERE 
    p.is_archived = 0 
    AND p.is_deleted = 0 

-- Group by user so that I can calculate per-user metrics
GROUP BY u.id, u.name

-- Only keep users who have BOTH: at least 1 savings plan AND at least 1 investment plan
HAVING 
    savings_count >= 1 
    AND investment_count >= 1

-- Sort results to show customers who deposited the most money first
ORDER BY total_deposits DESC;
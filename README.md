# DataAnalytics-Assessment
This repo contains my solutions for a SQL data assessment. The questions are real-world scenarios, mostly around customer behavior, savings and investment patterns. Everything here was written and tested by me using MySQL.

---

## Question 1 – High-Value Customers with Multiple Products

### Scenario:
The company is looking to spot customers who are both saving and investing — basically, those using both product types. This helps them know who they can upsell or cross-sell to.


### What Was Asked:
Get customers who:
- Have at least **one funded savings plan**
- Have at least **one funded investment plan**
- Then **sort them by their total deposits**


### My Approach:
1. From the `savings_savingsaccount` table, I picked only rows where `confirmed_amount > 0`, and joined it to `plans_plan` to make sure the plan is actually a **savings plan** (`is_regular_savings = 1`).
2. I also picked **investment plans** by checking `is_a_fund = 1` from the `plans_plan` table.
3. Then I grouped by user (`owner_id`) to count how many savings and investment plans each person has.
4. I calculated **total deposits** by summing `confirmed_amount`, and converted it from Kobo to Naira (divided by 100).
5. Finally, I filtered out anyone who doesn’t have **at least one** of both savings and investment, and sorted by `total_deposits` descending.


### Output Fields:
- `owner_id`
- `name`
- `savings_count`
- `investment_count`
- `total_deposits` (in Naira)


## Challenges I Faced

- First, I needed to be sure I was using the right flags to identify savings (`is_regular_savings`) and investment (`is_a_fund`) plans.
- Also had to remember that all money values are in **Kobo**, so I converted to Naira by dividing by 100.
- I made sure that if a customer didn’t meet both criteria (at least one savings + one investment), they wouldn’t show.
- Used `DISTINCT` where needed to avoid double counting from joins.

---
## Question 2 – Transaction Frequency Analysis

### Business Goal
The finance team wants to analyze how often customers transact so they can segment users into categories like "frequent", "moderate", and "low" users. This can guide targeted communication and product strategy.

### Task
Calculate the average number of transactions per customer per month and classify them as:

- **High Frequency** (≥10 transactions/month)  
- **Medium Frequency** (3–9 transactions/month)  
- **Low Frequency** (≤2 transactions/month)

### My Approach

1. **Step 1 – Get each customer's transaction history**  
   I used the `savings_savingsaccount` table to count how many transactions each customer (`owner_id`) made and to calculate how many months they’ve been active. I used `TIMESTAMPDIFF` between their first and last transaction month, and added `+1` to avoid division by zero.

2. **Step 2 – Calculate average monthly transactions**  
   I divided each customer’s total number of transactions by their active months to get the `avg_txn_per_month`.

3. **Step 3 – Categorize customers**  
   I used a `CASE` statement to assign customers into High, Medium, or Low frequency groups based on their average monthly transactions.

4. **Step 4 – Group and summarize**  
   I grouped the results by frequency category to count how many customers fall in each category and the average transactions per category.

5. **Optional Filter**  
   I added a commented-out line that filters only `'successful'` transactions. Depending on what the business wants (all attempts vs. successful ones), this line can be included or excluded.

6. **Sorting**  
   I used `FIELD()` to display results in a logical order: High → Medium → Low.

### Challenges
At first, only “Low Frequency” was showing. I discovered that many customers have limited transaction data in the sample set. This was not an error in the logic, just a reflection of the data. I decided to leave the transaction status filter commented out to make the result more inclusive and flexible.

---
## Question 3: Account Inactivity Alert

### Objective
Identify active accounts (either savings or investment) that have not received any inflow transactions in over a year (365 days).

### Approach
1. I combined data from both the savings_savingsaccount and plans_plan tables.

2. Grouped transactions by plan to find the most recent inflow (MAX(transaction_date)).

3. Filtered for only active and non-deleted plans using flags like is_deleted, is_archived, and is_goal_achieved.

4. Used DATEDIFF to compute the number of days since the last inflow.

5. Filtered the result to only show plans where inactivity_days > 365.

### Why This Matters
This insight is useful for operational monitoring. It allows the team to flag dormant accounts and possibly reach out to re-engage customers who haven’t saved or invested recently.

### Output Columns
Column	Description
plan_id	Unique identifier for the savings/investment plan
owner_id	User ID of the plan owner
type	'Savings' or 'Investment'
last_transaction_date	Date of the most recent inflow transaction
inactivity_days	Number of days since that transaction

### Challenges
Needed to differentiate Savings from Investments using is_regular_savings = 1 and is_a_fund = 1.

Ensured we excluded deleted or archived plans using filters like is_deleted = 0 and is_archived = 0.

Made sure only the last inflow was used for the date comparison by grouping by plan_id.

---
## Question 4: Customer Lifetime Value (CLV) Estimation

### Approach:

- Created two CTEs:
  - `customer_transactions` to aggregate total transactions and total confirmed transaction value for each customer.
  - `customer_tenure` to calculate account tenure in months from signup date to current date.
- Calculated average profit per transaction assuming 0.1% profit margin (hence dividing total confirmed amount by 1000).
- Computed estimated CLV using the formula:  
  **CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction**  
  This annualizes the monthly profit contribution.
- Used `NULLIF` to prevent division by zero errors for customers with zero tenure or transactions.
- Joined customer transaction data with tenure data to get comprehensive CLV metrics.
- Sorted the results by estimated CLV in descending order to highlight the highest value customers.

### Challenges:

- Handling customers with zero months of tenure or zero transactions required careful use of `NULLIF` to avoid division errors.
- Assumptions about profit per transaction simplified calculations but might not capture real-world complexity.
- Limited to savings transactions; investment transactions were not considered due to lack of explicit info.
- Ensured that profit calculation accounts for amounts stored in kobo by dividing by 1000 (to get the correct percentage).

### Summary:

This query provides a practical and simplified way to estimate Customer Lifetime Value (CLV) based on transaction activity and account tenure, useful for marketing segmentation and business strategy.


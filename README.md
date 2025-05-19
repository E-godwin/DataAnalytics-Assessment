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


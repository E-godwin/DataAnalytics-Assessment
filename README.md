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


## Small Challenges I Faced

- First, I needed to be sure I was using the right flags to identify savings (`is_regular_savings`) and investment (`is_a_fund`) plans.
- Also had to remember that all money values are in **Kobo**, so I converted to Naira by dividing by 100.
- I made sure that if a customer didn’t meet both criteria (at least one savings + one investment), they wouldn’t show.
- Used `DISTINCT` where needed to avoid double counting from joins.

---

## Repo Structure
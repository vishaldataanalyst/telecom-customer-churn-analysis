create schema telecome;
use telecome;
select * from telecom_churn limit 2;
describe telecom_churn;
-- Total revenue
 select sum(TotalCharges) as total_revenue from telecom_churn;
 -- Total revenue of company is nearly 29.2 crores
 -- max,min,avg and sum of munthly charges
SELECT
    MIN(MonthlyCharges) AS min_charge,
    MAX(MonthlyCharges) AS max_charge,
    AVG(MonthlyCharges) AS avg_charge,
    SUM(MonthlyCharges) AS total_charge
FROM telecom_churn;
-- Total churn customers
SELECT
    Churn,
    COUNT(*) AS total_customers
FROM telecom_churn
GROUP BY Churn;
-- Nearly 1/3 customers churned
select round(avg(TotalCharges),0) as average_revenue from telecom_churn;
-- Nearly every person is paying 2900
-- Gender wise churn customers
create view Gender_wise_churn as
SELECT 
    Churn, Gender, COUNT(*) AS total_customers
FROM
    telecom_churn
GROUP BY Churn , Gender;
select * from Gender_wise_churn;
-- Gender is not affecting churn
-- Top 10% churn customers
create VIEW  TOP_10_PER_CHURN AS 
SELECT *
FROM (
    SELECT *,
           NTILE(10) OVER (ORDER BY TotalCharges DESC) AS grp
    FROM telecom_churn
) t
WHERE grp = 1 and Churn ="Yes";
select * from TOP_10_PER_CHURN;
 select sum(TotalCharges) as churn_revenue from TOP_10_PER_CHURN;
 -- Nearly 3.6 crore ,company is loosing from top 10 % churn customers
 -- Churn revenue vs total revenue
 SELECT 
    (SELECT SUM(TotalCharges) FROM  telecom_churn where Churn="Yes") /
    (SELECT SUM(TotalCharges) FROM telecom_churn) * 100 AS percentage;
    -- churn customers gave 1/3 of total revenue

 
SELECT 
    (SELECT SUM(TotalCharges) FROM TOP_10_PER_CHURN) /
    (SELECT SUM(TotalCharges) FROM telecom_churn) * 100 AS percentage;
    -- 10 % of churn customers gave 12.3% of total revenue
    -- if we reduce half of top 10% churn customers that add nearly 1.78 crores in company revenue
    --  revenue of customers who in top 10% and all churn customers
SELECT 
    (SELECT SUM(TotalCharges) FROM TOP_10_PER_CHURN) /
    (SELECT SUM(TotalCharges) FROM telecom_churn where Churn="Yes") * 100 AS percentage;
    -- 0 % of churn customers gaveare give 36.9 % of total churn customers revenue
    select * from telecom_churn limit 2;
    -- Age wise Churn
    create view age_wise_churn_count as
    select Age,count(*) As total_churns
    from telecom_churn 
    where Churn="Yes"
    group by Age
    order by count(*) desc ;
    select *  from age_wise_churn_count;
    -- Every age of customers are churnning,range of churn count is(480-550)
    
    -- Age group wise churn
create view age_group_churn_count as
SELECT 
CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 50 THEN '36-50'
    ELSE '50+'
END AS age_group,
COUNT(*) AS churns
FROM telecom_churn
WHERE Churn = 'Yes'
GROUP BY age_group
ORDER BY churns DESC;
select * from age_group_churn_count;
 /*
Customers aged 50+ contribute nearly 47% of total churn, indicating this demographic is the most vulnerable segment.
 Telecom companies should design targeted retention strategies such as senior discounts, simplified plans,
 or loyalty benefits.
*/
-- Age ,churn and churn percentage
SELECT 
Age,
COUNT(*) AS churns,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS churn_percentage
FROM telecom_churn
WHERE Churn = 'Yes'
GROUP BY Age
ORDER BY churns DESC;
create view churn_revenue_age_wise as
SELECT 
CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 50 THEN '36-50'
    ELSE '50+'
END AS age_group,
round(SUM(TotalCharges),0) AS churn_revenue
FROM telecom_churn
WHERE Churn = 'Yes'
GROUP BY age_group
ORDER BY churn_revenue DESC;
select * from churn_revenue_age_wise;
/*
Customers aged 50+ contribute nearly 48% of total churn revenue 
 Retaining this segment should be the top priority for the telecom company as losing them significantly impacts overall revenue.
 */
-- Tenure vs Churn (most important churn predictor)
create view tenure_group_churn as
SELECT 
CASE 
    WHEN Tenure BETWEEN 1 AND 11 THEN '1-11'
    WHEN Tenure BETWEEN 12 AND 24 THEN '12-24'
    WHEN Tenure BETWEEN 25 AND 36 THEN '25-36'
    WHEN Tenure BETWEEN 37 AND 48 THEN '37-48'
    WHEN Tenure BETWEEN 49 AND 60 THEN '49-60'
    ELSE '60+'
END AS tenure_group,
COUNT(*) AS total_customers,
SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churn_customers
FROM telecom_churn
GROUP BY tenure_group
ORDER BY tenure_group;
select * from tenure_group_churn;
/*
Churn analysis shows that 67% of customers leave within the first 11 months,
 making early customer lifecycle the most critical stage for retention.
 Customers who stay beyond one year show significantly lower churn (~27%), indicating improved loyalty after the first year.
 */
 -- Contract wise costomers ,churn customers and churn percent
 SELECT Contract,
       COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churn_customers,
       ROUND(SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END)*100/COUNT(*),2) AS churn_rate
FROM telecom_churn
GROUP BY Contract;
-- Nearly 46.5 % customers are churnning from month to month contract
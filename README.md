# Target Brazil E-commerce SQL Analysis

SQL analysis of Target's Brazilian e-commerce operations using the Target Brazil e-commerce dataset. The project explores order trends, customer geography, sales and freight, delivery performance, and payment behavior through 17 business-focused queries written for Google BigQuery.

## Project Overview

This project turns transactional e-commerce data into practical business observations. The analysis covers when orders were placed, where customers and revenue are concentrated, how freight and delivery vary geographically, and how customers pay for purchases.

## Business Questions

- What period do the orders cover, and how have order volumes changed over time?
- When are orders most frequently placed?
- How are customers distributed across Brazilian cities and states?
- How do sales and freight costs vary by state?
- How does delivery performance vary across states, and how do actual delivery dates compare with estimates?
- Which payment methods are used, and how common are installments?

## Key Findings

- Order activity grew substantially in the earlier part of the observed period, then followed a more stable pattern during 2018.
- Orders are concentrated in the afternoon, particularly from about 1 p.m. to 6 p.m.
- Customer activity and revenue are concentrated in São Paulo, Rio de Janeiro, and Minas Gerais.
- Total freight is highest in high-volume states; average freight can be higher in smaller states, pointing to possible regional logistics cost differences.
- Delivery times vary by state. The analysis found that deliveries generally arrived before their estimated dates, suggesting the estimates included a buffer.
- Credit cards are the most-used payment method in the analyzed data. Most purchases use a single payment, while installment payments are also present.
- The report's like-for-like comparison of January–August 2017 with January–August 2018 calculated an approximately 136.98% increase in order costs.

These are descriptive findings from the project analysis; they do not establish the causes of the observed patterns.

## Business Recommendations

- Strengthen retention and repeat-purchase initiatives in high-volume states.
- Assess growth opportunities in states with meaningful activity below the top markets.
- Review freight performance by state, especially where average freight is relatively high.
- Use afternoon order patterns when planning customer campaigns and operational coverage.
- Review delivery estimates against actual delivery times to keep customer expectations clear while preserving reliable service.
- Continue monitoring payment method and installment preferences when planning checkout improvements.

## SQL Skills Demonstrated

- Filtering, sorting, grouping, and aggregation
- `JOIN` operations and subqueries
- Common Table Expressions (CTEs)
- `CASE` conditional logic
- Date and time extraction and calculations
- Window functions, including `LAG()` and `DENSE_RANK()`
- Period-over-period growth and percentage calculations
- Translating business questions into analytical queries

## Repository Structure

```text
target-brazil-ecommerce-sql-analysis/
├── README.md
├── target_analysis.sql
├── Target_SQL_Project.pdf
└── data/
    ├── customers.csv
    ├── orders.csv
    ├── order_items.csv
    ├── payments.csv
    ├── products.csv
    └── sellers.csv
```

The six CSV files listed are the proposed repository dataset files. The original materials also included `geolocation.csv` and `order_reviews.xlsx`; they are not listed here because the project notes recommended keeping those out of the initial repository. Confirm the uploaded repository contents match this structure before relying on the paths above.

## Dataset and Tools

- **Dataset:** Target Brazil e-commerce dataset supplied with the project materials.
- **Query environment:** Google BigQuery.
- **Language:** SQL (BigQuery SQL).
- **Supporting report:** `Target_SQL_Project.pdf`, containing the project report and query result examples.

The SQL file contains the 17 finalized queries, labeled to preserve the original business-case numbering. The queries were run individually in BigQuery and later assembled into the SQL file.

## Author

**Aravinth Baskar**  
Data Analytics / Data Science Portfolio Project

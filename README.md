# 📊 SEPETIX ANALYTICS - dBT Project

**Production-ready dBT project for e-commerce customer analytics and segmentation**

---

## 📋 Project Content

This dBT project performs **6 different analyses** on Sepetix e-commerce data:

### 1️⃣ Repeat Customers Analysis
- **File:** `models/marts/fct_repeat_customers.sql`
- **Purpose:** Identify customers with 2+ purchases
- **Output:** Customer LTV, category preferences, repeat purchase patterns
- **Key Finding:** 8 repeat customers identified, top customer spent ₺1,698

### 2️⃣ Churn Risk Segmentation
- **File:** `models/marts/fct_churn_risk.sql`
- **Purpose:** Segment customers by inactivity level
- **Segments:** Active, At Risk, Dormant, Churned
- **Key Finding:** 62 churned customers, 700+ days inactive

### 3️⃣ RFM Segmentation
- **File:** `models/marts/fct_rfm_segmentation.sql`
- **Purpose:** Customer value segmentation using Recency-Frequency-Monetary
- **Segments:** Champions, Loyal, At Risk, Lost, Potential
- **Key Finding:** 27 Loyal Customers generate 51.4% of total revenue

### 4️⃣ Cohort Analysis
- **File:** `models/marts/fct_cohort_analysis.sql`
- **Purpose:** Track customer cohort retention over time
- **KPI:** Month-over-month retention rate
- **Key Finding:** January 2024 cohort showed 95% churn after month 1

### 5️⃣ Product Affinity
- **File:** `models/marts/fct_product_affinity.sql`
- **Purpose:** Identify cross-selling opportunities (which categories sell together)
- **Use Case:** "Frequently Bought Together" recommendations

### 6️⃣ Incremental Orders Pipeline

- **File:** `models/marts/fct_orders_incremental.sql`
- **Purpose:** Process only new orders on each run — production-ready pipeline
- **Materialization:** Incremental (appends new rows only)
- **Key Achievement:** Connected dbt Core to BigQuery via OAuth, 135 rows processed, 4/4 data quality tests passed
---

## 🏗️ Project Structure


sepetix-dbt-analytics/
├── dbt_project.yml          # dBT configuration
├── .gitignore               # Sensitive files exclusion
├── README.md                # This file
├── models/
│   ├── staging/
│   │   └── stg_orders.sql   # Raw data cleanup & standardization
│   └── marts/
│       ├── fct_repeat_customers.sql
│       ├── fct_churn_risk.sql
│       ├── fct_rfm_segmentation.sql
│       ├── fct_cohort_analysis.sql
│       └── fct_product_affinity.sql

---

## 🚀 Setup & Running

### 1. Prerequisites
```bash
pip install dbt-bigquery
```

### 2. BigQuery Authentication
```bash
gcloud auth application-default login
```

### 3. Configure profiles.yml
- Update BigQuery project ID in `profiles.yml` (not included in repo for security)
- Set dataset name (default: `analytics`)

### 4. dBT Run
```bash
# Run all models (staging + marts)
dbt run

# Run only marts (skip staging)
dbt run --select tag:marts

# Run only staging
dbt run --select tag:staging

# Run specific model
dbt run --select fct_rfm_segmentation
```

### 5. Documentation Generate
```bash
dbt docs generate
dbt docs serve
```

---

## 📊 Models & Data Lineage

### DAG (Directed Acyclic Graph)

stg_orders (VIEW)
↓
├── fct_repeat_customers (TABLE)
├── fct_churn_risk (TABLE)
├── fct_rfm_segmentation (TABLE)
├── fct_cohort_analysis (TABLE)
└── fct_product_affinity (TABLE)

---

## 🎯 Key Metrics & Business Use Cases

### Repeat Customers (Customer Loyalty)
```sql
SELECT * FROM fct_repeat_customers
ORDER BY total_spent_lira DESC
LIMIT 20;
```
**Usage:** VIP customer selection, loyalty program design

### Churn Risk (Loss Prevention)
```sql
SELECT * FROM fct_churn_risk
WHERE churn_segment IN ('At Risk', 'Dormant')
ORDER BY days_since_purchase DESC;
```
**Usage:** Win-back campaigns, retention strategies

### RFM Segments (Customer Value)
```sql
SELECT rfm_segment, COUNT(*) as count, AVG(monetary_value) as avg_ltv
FROM fct_rfm_segmentation
GROUP BY rfm_segment
ORDER BY avg_ltv DESC;
```
**Usage:** Segment-specific marketing, budget allocation

### Cohort Retention (Customer Lifetime)
```sql
SELECT cohort_month, months_since_first_purchase, retention_rate_percent
FROM fct_cohort_analysis
WHERE months_since_first_purchase <= 6
ORDER BY cohort_month DESC;
```
**Usage:** Product-market fit analysis, customer lifecycle planning

### Product Affinity (Cross-sell)
```sql
SELECT * FROM fct_product_affinity
ORDER BY customer_count DESC;
```
**Usage:** "Frequently Bought Together" recommendations, bundling strategies

---

## ✅ Best Practices Implemented

- ✅ **Modular Architecture:** Staging → Marts separation
- ✅ **Self-Documenting:** schema.yml with column descriptions
- ✅ **Data Quality:** NOT NULL and UNIQUE tests
- ✅ **Performance:** Optimal materialization (VIEW vs TABLE)
- ✅ **Scalability:** CTEs for reusable logic
- ✅ **Security:** .gitignore for sensitive files
- ✅ **Naming Convention:** fct_ (facts), stg_ (staging), dim_ (dimensions)

---

## 🔧 Advanced Usage

### Add Tests
```bash
# Run tests defined in schema.yml
dbt test

# Test specific model
dbt test --select fct_repeat_customers
```

### Fresh Run (Clear + Rebuild)
```bash
dbt clean
dbt run
```

### Generate Lineage Graph
```bash
dbt docs generate
dbt docs serve
# Opens at http://127.0.0.1:8080
```

---

## 🩺 Troubleshooting

### "Permission denied" BigQuery error
- Verify write permissions on BigQuery dataset
- Check project ID in your local `profiles.yml`

### Models won't build
```bash
dbt debug   # Test connection and config
dbt run --debug  # Run with detailed logging
```

### Slow performance
- Check `materialized='table'` in `models/marts/*.sql`
- Optimize BigQuery shuffling (proper GROUP BY order)

---

## 🎓 Learning Path

1. **Staging Layer (stg_orders.sql):** Raw data → Clean data
2. **Repeat Customers (fct_repeat_customers.sql):** GROUP BY, aggregations
3. **Churn Risk (fct_churn_risk.sql):** CASE WHEN, business logic
4. **RFM (fct_rfm_segmentation.sql):** NTILE window functions, segmentation
5. **Cohort (fct_cohort_analysis.sql):** Complex joins, retention calculations
6. **Product Affinity (fct_product_affinity.sql):** ARRAY operations, UNNEST

---

## 📈 Next Steps

- [x] Implement **incremental models** (process only new data) ✅
- [x] Add **dBT tests** (comprehensive data quality checks) ✅
- [ ] Create **Looker/Tableau dashboard** for metrics visualization
- [ ] Setup **dBT Cloud** for scheduled automated runs
- [ ] Build **macros** for reusable transformations

---

## 👩‍💻 Author & Contact

**Author:** Zeliha Tutar
**LinkedIn:** [linkedin.com/in/zeliha-tutar-35a3013aa](https://linkedin.com/in/zeliha-tutar-35a3013aa)
**Created:** 2026
**Purpose:** Analytics Engineer Portfolio Project
**Target:** Remote roles in UK/Germany

---

*Happy Analyzing!* 🎉



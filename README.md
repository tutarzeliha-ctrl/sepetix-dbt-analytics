# Sepetix dbt Analytics Project

A data transformation project demonstrating **staging/mart architecture** with dbt and SQLite.

## 🎯 Overview

This project showcases data engineering best practices: building maintainable data pipelines, implementing data quality tests, and auto-generating documentation. It transforms raw ecommerce data into analysis-ready tables.

## 🏗️ Architecture

**Staging Layer:** Raw data cleaning & standardization
- Clean data quality issues
- Standardize naming conventions
- Cast data types

**Mart Layer:** Business-ready analytics tables
- Answer specific business questions
- Join staging models into insights
- Support dashboards and reports

## 📊 Models

1. **stg_orders** - Customer orders with status tracking
   - Columns: order_id, customer_id, status, amount
   - Source: Raw Sepetix orders data

2. **mart_customer_summary** - Aggregated customer metrics
3. **mart_order_analysis** - Order performance analysis
4. **mart_category_insights** - Category-level analytics
5. **mart_geographic_trends** - Regional patterns

## ✅ Data Quality Testing

All 4 tests passing:
- ✓ order_id is unique (no duplicates)
- ✓ order_id is not null (completeness)
- ✓ customer_id is not null (integrity)
- ✓ status has valid values (domain constraint)

Tests ensure downstream data reliability and prevent silent failures.

## 🛠️ Technology Stack

- **dbt** 1.11.7 - Data transformation framework
- **SQLite** - Data warehouse
- **Python** 3.12 - For orchestration & utilities

## 📁 Project Structure

## 🚀 How to Run

1. **Install dependencies**
```bash
   pip install dbt-core dbt-sqlite
```

2. **Run transformations**
```bash
   dbt run
```

3. **Run data quality tests**
```bash
   dbt test
```

4. **Generate documentation**
```bash
   dbt docs generate
   dbt docs serve
```

## 🎓 What I Learned

- **Staging/Mart Separation:** Clean architecture improves maintainability. When requirements change, I only update marts, not staging.
- **Data Quality Tests:** Critical for reliability. Tests that fail prevent bad data from reaching dashboards.
- **dbt Best Practices:** ref() for dependencies, source() for raw data, macros for reusability.
- **Modeling Patterns:** CASE WHEN for business logic, GROUP BY for aggregation, efficient JOINs.
- **Documentation:** Auto-generated docs reduce manual maintenance and improve team clarity.

## 👤 Author

**Zeliha Tutar**  
Analytics Engineer | Decision Intelligence | SQL • Python • BigQuery  
📍 Turkey | 🌐 Remote  

**Links:**
- 🔗 [LinkedIn][(https://linkedin.com/in/zelihaturar)](https://www.linkedin.com/in/zeliha-tutar-35a3013aa/)
- 💻 [GitHub](https://github.com/tutarzeliba-ctrl)

---

**Key Takeaway:** This project demonstrates how data engineering enables better business decisions. Clean data + reliable pipelines + clear documentation = trust.

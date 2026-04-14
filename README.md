
# 📊 SEPETIX ANALYTICS - dBT Project

**E-commerce müşteri analizi ve segmentasyonu için production-ready dBT projesi**

---

## 📋 Proje İçeriği

Bu dBT projesi, Sepetix e-commerce verilerinden **5 farklı analiz** yapıyor:

### 1️⃣ **Repeat Customers Analizi**
- Dosya: `models/marts/fct_repeat_customers.sql`
- Amaç: En az 2 kez sipariş veren müşterileri tanımla
- Output: Customer LTV, category preferences, repeat purchase patterns

### 2️⃣ **Churn Risk Segmentasyonu**
- Dosya: `models/marts/fct_churn_risk.sql`
- Amaç: Müşterileri inaktivite seviyesine göre segment'le
- Segment'ler: Active, At Risk, Dormant, Churned

### 3️⃣ **RFM Segmentasyonu**
- Dosya: `models/marts/fct_rfm_segmentation.sql`
- Amaç: Recency-Frequency-Monetary ile customer value segment'leri
- Segment'ler: Champions, Loyal, At Risk, Lost, Potential

### 4️⃣ **Cohort Analysis**
- Dosya: `models/marts/fct_cohort_analysis.sql`
- Amaç: Müşteri cohort'larının retention'unu izle
- KPI: Month-over-month retention rate

### 5️⃣ **Product Affinity**
- Dosya: `models/marts/fct_product_affinity.sql`
- Amaç: Cross-selling fırsatlarını tanımla (hangi kategoriler beraber satılıyor?)
- Use Case: "Frequently Bought Together" recommendations

---

## 🏗️ Proje Yapısı

```
sepetix_analytics/
├── dbt_project.yml          # dBT configuration
├── profiles.yml             # Database connection (BigQuery)
├── .gitignore              # Sensitive files
├── README.md               # Bu dosya
├── models/
│   ├── staging/
│   │   └── stg_orders.sql       # Raw data cleanup & standardization
│   └── marts/
│       ├── fct_repeat_customers.sql
│       ├── fct_churn_risk.sql
│       ├── fct_rfm_segmentation.sql
│       ├── fct_cohort_analysis.sql
│       └── fct_product_affinity.sql
├── tests/                   # (Opsiyonel) Data quality tests
├── macros/                  # (Opsiyonel) Reusable SQL functions
└── seeds/                   # (Opsiyonel) Static lookup tables
```

---

## 🚀 Setup & Running

### 1. **Prerequisites**
```bash
pip install dbt-bigquery
```

### 2. **BigQuery Authentication**
```bash
gcloud auth application-default login
```

### 3. **Configure profiles.yml**
- BigQuery project ID'ni `profiles.yml`'de güncelle
- Dataset adını (default: `analytics`) ayarla

### 4. **dBT Run**
```bash
# Tüm models'ı çalıştır (staging + marts)
dbt run

# Sadece marts çalıştır (staging skip)
dbt run --select tag:marts

# Sadece staging çalıştır
dbt run --select tag:staging

# Specific model çalıştır
dbt run --select fct_rfm_segmentation
```

### 5. **Documentation Generate**
```bash
dbt docs generate
dbt docs serve
```

---

## 📊 Models & Data Lineage

### DAG (Directed Acyclic Graph)
```
stg_orders (VIEW)
    ↓
    ├→ fct_repeat_customers (TABLE)
    ├→ fct_churn_risk (TABLE)
    ├→ fct_rfm_segmentation (TABLE)
    ├→ fct_cohort_analysis (TABLE)
    └→ fct_product_affinity (TABLE)
```

---

## 🎯 Key Metrics & Business Use Cases

### Repeat Customers (Müşteri Sadakati)
```sql
SELECT * FROM fct_repeat_customers
ORDER BY total_spent_lira DESC
LIMIT 20;
```
**Kullanım:** VIP müşteri seçimi, loyalty program design

### Churn Risk (Kayıp Riski)
```sql
SELECT * FROM fct_churn_risk
WHERE churn_segment IN ('At Risk', 'Dormant')
ORDER BY days_since_purchase DESC;
```
**Kullanım:** Win-back kampanyaları, retention stratejileri

### RFM Segments (Müşteri Değeri)
```sql
SELECT rfm_segment, COUNT(*) as count, AVG(monetary_value) as avg_ltv
FROM fct_rfm_segmentation
GROUP BY rfm_segment
ORDER BY avg_ltv DESC;
```
**Kullanım:** Segment-specific marketing, budget allocation

### Cohort Retention (Müşteri Ömrü)
```sql
SELECT cohort_month, months_since_first_purchase, retention_rate_percent
FROM fct_cohort_analysis
WHERE months_since_first_purchase <= 6
ORDER BY cohort_month DESC;
```
**Kullanım:** Product-market fit analizi, customer lifecycle planning

### Product Affinity (Cross-sell)
```sql
SELECT * FROM fct_product_affinity
ORDER BY customer_count DESC;
```
**Kullanım:** "Frequently Bought Together" recommendations, bundling strategies

---

## ✅ Best Practices Implemented

- ✅ **Modular Architecture:** Staging → Marts separation
- ✅ **Self-Documenting:** schema.yml ile column descriptions
- ✅ **Data Quality:** NOT NULL ve UNIQUE tests
- ✅ **Performance:** Optimal materialization (VIEW vs TABLE)
- ✅ **Scalability:** CTEs ile reusable logic
- ✅ **Security:** .gitignore sensitive files
- ✅ **Naming Convention:** fct_ (facts), stg_ (staging), dim_ (dimensions)

---

## 🔧 Advanced Usage

### Add Tests
```bash
# schema.yml'de tanımlanan testleri çalıştır
dbt test

# Specific model test
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
# http://127.0.0.1:8000 açılır
```

---

## 📞 Troubleshooting

### "Permission denied" BigQuery error
- BigQuery dataset'ine write permission'ı kontrol et
- `profiles.yml`'deki project ID'yi doğrula

### Models build olmuyorsa
```bash
dbt debug  # Bağlantı ve config'i test et
dbt run --debug  # Detailed log ile çalıştır
```

### Slow performance
- `models/marts/*.sql`'deki `materialized='table'` kontrol et
- BigQuery'de data shuffling'i optimize et (GROUP BY order)

---

## 🎓 Learning Path

1. **Staging Layer (stg_orders.sql):** Raw data'dan temiz data'ya
2. **Repeat Customers (fct_repeat_customers.sql):** GROUP BY, aggregations
3. **Churn Risk (fct_churn_risk.sql):** CASE WHEN, business logic
4. **RFM (fct_rfm_segmentation.sql):** NTILE windows functions, segmentation
5. **Cohort (fct_cohort_analysis.sql):** Complex joins, retention calculations
6. **Product Affinity (fct_product_affinity.sql):** ARRAY operations, UNNEST

---

## 📈 Next Steps

- [ ] Implement **incremental models** (sadece yeni veriyi işle)
- [ ] Add **dbt tests** (data quality checks)
- [ ] Create **Looker/Tableau dashboard** ile metrics'leri visualize et
- [ ] Setup **dbt Cloud** ile scheduled runs
- [ ] Build **macros** ile reusable transformations

---

## 📚 Resources

- [dBT Documentation](https://docs.getdbt.com)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices)
- [RFM Analysis Guide](https://www.optimizesmart.com/rfm-analysis/)
- [Cohort Analysis Guide](https://blog.amplitude.com/understanding-cohort-analysis)

---

## 👨‍💼 Author & Contact

**Project:** Sepetix Analytics dBT Project
**Created:** 2025
**Purpose:** Analytics Engineer Interview Preparation (May deadline ✅)
**Focus:** UK/Germany Remote Role

---

**Happy Analyzing! 🚀**

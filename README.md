\# Sepetix Local dbt Project



A data transformation project built with dbt and SQLite.



\## Models



\- \*\*sepetix\_orders\*\*: Customer orders with status tracking

&#x20; - Columns: order\_id, customer\_id, status, amount

&#x20; - Tests: unique, not\_null, accepted\_values



\## Running the Project

```bash

dbt run

dbt test

dbt docs generate

```



\## Testing



All 4 data quality tests pass:

\- ✅ order\_id is unique

\- ✅ order\_id is not null

\- ✅ customer\_id is not null

\- ✅ status has valid values (completed, pending, cancelled)



\## Technology Stack



\- dbt 1.11.7

\- SQLite

\- Python 3.12


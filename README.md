# OLAP-Training Playground

A tiny, self-contained project to practise **Lakehouse → OLAP** loading patterns with nothing more than **Polars**, **DuckDB**, and a local **PostgreSQL** instance.

---

## What the script does

**Loads NYX Yellow-Taxi data into Postgres via DuckDB**  
   ```text
   Polars DataFrame  →  DuckDB temp view
                     →  DuckDB postgres extension
                     →  CREATE OR REPLACE TABLE … IN Postgres
# nyx_taxi_db_loader

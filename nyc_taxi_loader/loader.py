from glob import glob

import duckdb
import polars
import polars as pl


def load_to_postgres(pl_df: polars.DataFrame, output_table: str):
    con = duckdb.connect()
    con.execute("INSTALL postgres;")
    con.execute("LOAD postgres;")
    con.register("pl_df", pl_df)
    con.execute(
        "ATTACH 'dbname=postgres user=postgres host=127.0.0.1' AS db (TYPE postgres, SCHEMA 'public');"
    )
    con.execute(f"""
        CREATE OR REPLACE TABLE db.{output_table} AS
        SELECT * FROM pl_df;
    """)
    con.close()


if __name__ == "__main__":
    dfs = []
    for f in glob("data/yellow_taxis/yellow_tripdata_*.parquet"):
        df = pl.read_parquet(f).with_columns(
            [
                pl.col("tpep_pickup_datetime").cast(pl.Datetime("ns")),
                pl.col("tpep_dropoff_datetime").cast(pl.Datetime("ns")),
            ]
        )
        dfs.append(df)
    taxis_df = pl.concat(dfs)

    lookup_df = pl.read_csv("data/taxi_zone_lookup.csv")
    load_to_postgres(taxis_df, "taxi")
    load_to_postgres(lookup_df, "locations")

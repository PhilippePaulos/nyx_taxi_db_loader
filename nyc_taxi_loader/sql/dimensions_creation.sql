-- ========================================
-- Drop existing tables if they exist
-- ========================================

DROP TABLE IF EXISTS dim_time CASCADE;
DROP TABLE IF EXISTS dim_vendor CASCADE;
DROP TABLE IF EXISTS dim_location CASCADE;
DROP TABLE IF EXISTS fact_trips CASCADE;

-- ========================================
-- Create dim_time
-- ========================================

CREATE TABLE dim_time (
    date_id       DATE PRIMARY KEY,
    year          INT,
    month         INT,
    day           INT,
    day_of_week   VARCHAR,
    week_of_year  INT,
    quarter       INT
);

INSERT INTO dim_time (
    date_id,
    year,
    month,
    day,
    day_of_week,
    week_of_year,
    quarter
)
SELECT
    gs::DATE                 AS date_id,
    EXTRACT(YEAR FROM gs)    AS year,
    EXTRACT(MONTH FROM gs)   AS month,
    EXTRACT(DAY FROM gs)     AS day,
    TO_CHAR(gs, 'Day')       AS day_of_week,
    EXTRACT(WEEK FROM gs)    AS week_of_year,
    EXTRACT(QUARTER FROM gs) AS quarter
FROM generate_series(
    '2024-01-01'::DATE,
    '2025-12-31'::DATE,
    INTERVAL '1 day'
) AS gs;

-- ========================================
-- Create dim_vendor
-- ========================================

CREATE TABLE dim_vendor (
    vendor_id    VARCHAR PRIMARY KEY,
    vendor_name  TEXT,
    description  TEXT
);

INSERT INTO dim_vendor (vendor_id, vendor_name, description)
VALUES
    ('1', 'Creative Mobile Technologies, LLC (CMT)', 'One of the two main taxi technology providers in NYC'),
    ('2', 'VeriFone Inc. (VTS)', 'Another main taxi technology provider in NYC'),
    ('6', 'NYC Green Taxi Cooperative', 'A cooperative providing green taxi services in outer boroughs'),
    ('7', 'Metro Taxi Fleet Services', 'A mid-sized fleet operator offering yellow cab and hybrid services in NYC');

-- ========================================
-- Create dim_location
-- ========================================

CREATE TABLE dim_location (
    location_id  INT4 PRIMARY KEY,
    borough      VARCHAR,
    zone         VARCHAR
);

INSERT INTO dim_location
SELECT
    "LocationID",
    "Borough",
    "Zone"
FROM locations;

-- ========================================
-- Create fact_trips
-- ========================================

CREATE TABLE fact_trips (
    trip_id          SERIAL PRIMARY KEY,
    pickup_date      DATE REFERENCES dim_time(date_id),
    dropoff_date     DATE REFERENCES dim_time(date_id),
    vendor_id        VARCHAR REFERENCES dim_vendor(vendor_id),
    pickup_location  INT REFERENCES dim_location(location_id),
    dropoff_location INT REFERENCES dim_location(location_id),
    tips             FLOAT,
    price            FLOAT,
    trip_distance    FLOAT,
    passengers       INT
);

-- ========================================
-- Insert into fact_trips
-- ========================================

INSERT INTO fact_trips (
    pickup_date,
    dropoff_date,
    vendor_id,
    pickup_location,
    dropoff_location,
    tips,
    price,
    trip_distance,
    passengers
)
SELECT
    tpep_pickup_datetime::DATE,
    tpep_dropoff_datetime::DATE,
    "VendorID",
    "PULocationID",
    "DOLocationID",
    tip_amount,
    total_amount,
    trip_distance,
    passenger_count
FROM taxi;

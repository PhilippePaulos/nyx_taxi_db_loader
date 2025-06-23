-- Drop & create table
DROP TABLE IF EXISTS trade_ticks;
CREATE TABLE trade_ticks (
  trade_id SERIAL PRIMARY KEY,
  ticker VARCHAR,
  trade_time TIMESTAMP,
  price FLOAT,
  volume INT
);

-- Sample data
INSERT INTO trade_ticks (ticker, trade_time, price, volume) VALUES
('AAPL', '2024-06-21 09:00:00', 190.5, 100),
('AAPL', '2024-06-21 09:10:00', 191.0, 200),
('AAPL', '2024-06-21 09:25:00', 192.0, 150),
('AAPL', '2024-06-21 09:45:00', 193.5, 250),
('AAPL', '2024-06-21 10:00:00', 194.0, 300),
('AAPL', '2024-06-21 11:00:00', 195.0, 300),
('AAPL', '2024-06-21 11:00:00', 195.0, 300);


SELECT
  trade_id,
  ticker,
  trade_time,
  price,
  AVG(price) OVER (
    PARTITION BY ticker
    ORDER BY trade_time
    RANGE BETWEEN INTERVAL '30 minutes' PRECEDING AND current row
  ) AS ma_30min
FROM trade_ticks
ORDER BY trade_time;


-- For each ticker, calculate the daily change in position_size (today’s minus yesterday’s).
SELECT
  ticker,
  snapshot_date,
  position_size,
  position_size - LAG(position_size) OVER (
    PARTITION BY ticker
    ORDER BY snapshot_date
  ) AS daily_change
FROM positions
ORDER BY ticker, snapshot_date;



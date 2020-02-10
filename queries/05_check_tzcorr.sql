SELECT
  DEP_DELAY,
  AVG(ARR_DELAY) as arrival_delay,
  STDDEV(ARR_DELAY) as stddev_arrival_delay,
  COUNT(ARR_DELAY) AS numflights
FROM
  `flights.tzcorr`
GROUP BY
  DEP_DELAY
HAVING
  numflights > 370
ORDER BY
  DEP_DELAY


SELECT 
  --除外されたフライト数
  6264906 - SUM(numflights) AS num_removed, 
  -- 到着時間から出発時間を予測する線形モデルの傾き
  AVG(arrival_delay * numflights)/AVG(DEP_DELAY * numflights) AS lm 
FROM (
  SELECT
    DEP_DELAY,
    AVG(ARR_DELAY) as arrival_delay,
    STDDEV(ARR_DELAY) as stddev_arrival_delay,
    COUNT(ARR_DELAY) AS numflights
  FROM
    `flights.tzcorr`
  GROUP BY
    DEP_DELAY
  ORDER BY
    DEP_DELAY
)
WHERE numflights > 1000

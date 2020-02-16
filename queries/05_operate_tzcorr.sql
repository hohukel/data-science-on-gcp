SELECT *
FROM (
  SELECT
    ORIGIN,
    AVG(DEP_DELAY) as dep_delay,
    AVG(ARR_DELAY) as arr_delay,
    COUNT(ARR_DELAY) as num_flights
  FROM
    flights.tzcorr
  GROUP BY ORIGIN
)
WHERE num_flights > 3650
ORDER BY dep_delay DESC


SELECT
  ORIGIN,
  AVG(DEP_DELAY) as dep_delay,
  AVG(ARR_DELAY) as arr_delay,
  COUNT(ARR_DELAY) as num_flights
FROM
  flights.tzcorr
GROUP BY ORIGIN
HAVING
  num_flights > 3650
ORDER BY dep_delay DESC
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
)
WHERE numflights > 1000
ORDER BY
  DEP_DELAY



SELECT
  DEP_DELAY,
  APPROX_QUANTILES(ARR_DELAY, 101)[OFFSET(70)] AS arrival_delay,
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
  ORIGIN,
  DEST,
  DEP_DELAY,
  ARR_DELAY,
FROM
  `flights.tzcorr`
WHERE
  RAND() > 0.7


SELECT
  FL_DATE,
  -- ハッシュ化, 整数化, 100でmod取る, 70以下か確認
  IF(MOD(ABS(FARM_FINGERPRINT(CAST(FL_DATE AS STRING))),100) < 70, 'True','False') AS is_train_day
FROM (
  SELECT
    DISTINCT(FL_DATE) AS FL_DATE,
  FROM
    flights.tzcorr
)
ORDER BY
  FL_DATE


SELECT
  SUM(IF(DEP_DELAY < 16 AND ARR_DELAY < 15, 1, 0)) AS correct_nocancel,
  SUM(IF(DEP_DELAY < 16 AND ARR_DELAY >= 15, 1, 0)) AS wrong_nocancel,
  SUM(IF(DEP_DELAY >= 16 AND ARR_DELAY >= 15, 1, 0)) AS correct_cancel,
  SUM(IF(DEP_DELAY >= 16 AND ARR_DELAY < 15, 1, 0)) AS wrong_cancel
FROM (
  SELECT
    DEP_DELAY,
    ARR_DELAY
  FROM
    `flights.tzcorr` f
  JOIN
    `flights.trainday` t
  ON
    f.FL_DATE = t.FL_DATE
  WHERE
    t.is_train_day = 'False'
)

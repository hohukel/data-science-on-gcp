--SELECT *
--FROM (
  --SELECT
    --ORIGIN,
    --AVG(DEP_DELAY) as dep_delay,
    --AVG(ARR_DELAY) as arr_delay,
    --COUNT(ARR_DELAY) as num_flights
  --FROM
    --flights.tzcorr
  --GROUP BY ORIGIN
--)
--WHERE num_flights > 3650
--ORDER BY dep_delay DESC
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

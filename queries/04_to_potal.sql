SELECT 
  airport,
  last[safe_OFFSET(0)].*,
  CONCAT(CAST(last[safe_OFFSET(0)].latitude AS STRING),",",\
  CAST(last[safe_OFFSET(0)].longitude AS STRING)) as location
FROM (
  SELECT
    airport,
    ARRAY_AGG(STRUCT(arr_delay,
      dep_delay,
      timestamp,
      latitude,
      longitude,
      num_flights)
    ORDER BY
      timestamp DESC
    LIMIT 1
    ) last
  FROM flights.streaming_delays
  GROUP BY airport
)

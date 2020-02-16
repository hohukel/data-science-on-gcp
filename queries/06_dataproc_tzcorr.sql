SELECT
  DISTANCE, DEP_DELAY
FROM `flights.tzcorr`
WHERE RAND() < 0.001 
  AND dep_delay > -20 
  AND dep_delay < 30 
  AND distance < 2000


-- 出発遅延時間の閾値のみでキャンセルするかを判断した場合(ch05)
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

-- 出発遅延時間, フライト距離でキャンセルするかを判断した場合(ch06)
-- フライト距離が長いほど取り返せる
SELECT
  SUM(IF(DEP_DELAY = 15 AND ARR_DELAY < 15, 1, 0)) AS wrong_cancel,
  SUM(IF(DEP_DELAY = 15 AND ARR_DELAY >= 15, 1, 0)) AS correct_cancel
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
    AND f.DISTANCE < 342
)



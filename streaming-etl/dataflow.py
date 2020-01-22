import apache_beam as beam
import csv

def addtimezone(lat, lon):
    try:
        import timezonefinder
        tf = timezonefinder.TimezoneFinder()
        tz = tf.timezone_at(lng=float(lon), lat=float(lat)) # throws ValueError
        if tz is None:
            tz = 'UTC'
        return (lat, lon, tz)
    except ValueError:
        return lat, lon, 'TIMEZONE' # これがヘッダーになる

def as_utc(date, hhmm, tzone):
    try:
        if len(hhmm) > 0 and tzone is not None:
            import datetime, pytz
            loc_tz = pytz.timezone(tzone)
            loc_dt = loc_tz.localize(datetime.datetime.strptime(date, '%Y-%m-%d'), is_dst=False)
            loc_dt += datetime.timedelta(hours=int(hhmm[:2]), minutes=int(hhmm[2:]))

            utc_dt = loc_dt.astimezone(pytz.utc)
            return utc_dt.strftime('%Y-%m-%d %H:%M:%S'), loc_dt.utcoffset().total_seconds()
        else:
            return '',0 # empty string corresponds to canceled flights
    except ValueError as e:
        print ('{} {} {}'.format(date, hhmm, tzone))
        raise e

def add_24h_if_before(arrtime, deptime):
   import datetime
   if len(arrtime) > 0 and len(deptime) > 0 and arrtime < deptime:
      adt = datetime.datetime.strptime(arrtime, '%Y-%m-%d %H:%M:%S')
      adt += datetime.timedelta(hours=24)
      return adt.strftime('%Y-%m-%d %H:%M:%S')
   else:
      return arrtime

# line:読み込んだフライトデータ1行分, airports_timezones:全ての空港のタイムゾーン情報を含むディクショナリ
def tz_correct(line, airport_timezones):
    fields = line.split(',')
    if fields[0] != 'FL_DATE' and len(fields) == 27:
        # convert all times to UTC
        dep_airport_id = fields[6]
        arr_airport_id = fields[10]
        # (lat, lon, tz)のインデックス2なのでタイムゾーン
        dep_timezone = airport_timezones[dep_airport_id][2]
        arr_timezone = airport_timezones[arr_airport_id][2]

        """
        Data example:
            fields[13], fields[14], fields[17], fields[18], fields[20], fields[21]
            -> '1725', '1714', '1733', '2055', '2110', '2100'
        これらの時間に関するカラムをutcに変換してY-M-D HMSの形にする
        """
        for f in [13, 14, 17]: # crsdeptime, deptime, whellsoff
            fields[f], deptz = as_utc(fields[0], fields[f], dep_timezone)
        for f in [18, 20, 21]: # wheelson, crsarrtime, arrtime
            fields[f], arrtz = as_utc(fields[0], fields[f], arr_timezone)
        for f in [17, 18, 20, 21]: # crsdeptime以外の時間をdeptimeと比較
            fields[f] = add_24h_if_before(fields[f], fields[14])

        # 出発空港, 到着空港の(lat, lon, tz)をextend
        fields.extend(airport_timezones[dep_airport_id])
        fields[-1] = str(deptz)
        fields.extend(airport_timezones[arr_airport_id])
        fields[-1] = str(arrtz)

        yield ','.join(fields)

if __name__ == '__main__':
    with beam.Pipeline('DirectRunner') as pipeline:

        airports = (pipeline
            | 'airports:read' >> beam.io.ReadFromText('airports.csv.gz')
            | 'airports:fields' >> beam.Map(lambda line: next(csv.reader([line])))
            | 'airports:tz' >> beam.Map(lambda fields: (
                     fields[0], addtimezone(fields[21], fields[26])
                ))
        )
        
        # 空港データをサイドインプット
        # pvalue.AsDict: PCollectionを空港IDをキーとするディクショナリに変換
        flights = (pipeline
            | 'flights:read' >> beam.io.ReadFromText('201501_part.csv')
            | 'flights:tzcorr' >> beam.FlatMap(tz_correct, beam.pvalue.AsDict(airports))
        ) 

        flights | beam.io.textio.WriteToText('results/all_flights')

        pipeline.run()

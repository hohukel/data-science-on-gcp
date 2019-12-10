import os
import logging
import flask

import ingest_flights # self module

app = flask.Flask(__name__)

# [start config]
CLOUD_STORAGE_BUCKET = os.environ['CLOUD_STORAGE_BUCKET']
logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)
# [end config]

@app.route('/')
def welcome():
    return '<html><a href="ingest">ingest next month</a> flight data</html>'

@app.route('/ingest')
def ingest_next_month():
    try:
        # cron ジョブからのリクエストか確認 異なる場合 KeyError発生
        is_cron = flask.request.headers['X-Appenvine-Cron']
        logging.info('Received cron request {}'.format(is_cron))

        # 最新のデータの翌月を取得
        bucket = CLOUD_STORAGE_BUCKET
        year, month = ingest_flights.next_month(bucket)
        logging.info('ingesting year={}, month={}'.format(year, month))

        # ingest実行
        gcsfile = ingest_flights.ingest(year, month, bucket)

        # return page, and log
        status = 'Successfully ingested from BTS to {}'.format(gcsfile)

    except ingest_flights.DataUnavalible:
        statut = 'File for {}-{} not available yet ...'.format(year, month)

    except KeyError as e:
        logging.info('Rejected non Cron request')

    logging.info(status)
    return status

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

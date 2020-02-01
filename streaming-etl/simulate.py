import time
import pytz
import logging
import argparse
import datetime
from google.cloud import pubsub
import google.cloud.bigquery as bq

TIME_FORMAT = '%Y-%m-%d %H:%M:%S %Z'
RFC3339_TIME_FORMAT = '%Y-%m-%dT%H:%M:%S-00:00'

def publish(publisher, topics, allevents, notify_time):
    timestamp =notify_time.strftime(RFC3339_TIME_FORMAT)
    for key in topics: # departed, arrived etc..
        topic = topics[key]
        events = allevents[key]
        # the client automatically batches
        logging.info('Publishing {} {} till {}'.format(len(events), key, timestamp))
        for event_data in events:
            publisher.publish(topic, event_data.encode(), EventTimeStamp=timestamp)

def notify(publisher, topics, rows, simStartTime, programStart, speedFactor):
    # sleep computation
    def compute_sleep_secs(notify_time):
        time_elapsed = (datetime.datetime.utcnow() - programStart).seconds
        sim_time_elapsed = (notify_time - simStartTime).seconds / speedFactor
        to_sleep_secs =sim_time_elapsed - time_elapsed
        return to_sleep_secs

    tonotify = {}
    for key in topics:
        tonotify[key] = list()

    for row in rows:
        event, notify_time, event_data = row

        # how much time should we sleep?
        if compute_sleep_secs(notify_time) > 1:
            publish(publisher, topics, tonotify, notify_time)
            for key in topics:
                tonotify[key] = list()

            # recompute sleep, since notification takes a while
            to_sleep_secs = compute_sleep_secs(notify_time)
            if to_sleep_secs > 0:
                logging.info('Sleeping {} seconds'.format(to_sleep_secs))
                time.sleep(to_sleep_secs)
            tonotify[event].append(event_data)

    publish(publisher, topics, tonotify, notify_time)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Send simulated flight events to Cloud Pub/Sub')
    parser.add_argument('--startTime',
        help='Ex: 2015-05-01 00:00:00 UTC', required=True)
    parser.add_argument('--endTime',
        help='Ex: 2015-05-03 00:00:00 UTC', required=True)
    parser.add_argument('--project',
        help='your project id, to create pubsub topic', required=True)
    parser.add_argument('--speedFactor',
        help='Ex: 60 implies 1 hour of data sent to Cloud Pub/Sub in 1 minute',
        required=True, type=float)
    parser.add_argument('--jitter',
        help='type of jitter to add: None, uniform, exp are the three options',
        default='None')

    logging.basicConfig(format='(levelname)s: %(message)s', level=logging.INFO)

    args = parser.parse_args()

    bqclient = bq.Client(args.project)
    dataset = bqclient.get_dataset(bqclient.dataset('flights'))

    if args.jitter == 'exp':
      jitter = 'CAST (-LN(RAND()*0.99 + 0.01)*30 + 90.5 AS INT64)'
    elif args.jitter == 'uniform':
      jitter = 'CAST(90.5 + RAND()*30 AS INT64)'
    else:
      jitter = '0'

    # run the query to pull simulated events
    querystr = """\
        SELECT
          EVENT,
          TIMESTAMP_ADD(NOTIFY_TIME, INTERVAL {} SECOND) AS NOTIFY_TIME,
          EVENT_DATA
        FROM flights.simevents
        WHERE
          NOTIFY_TIME >= TIMESTAMP('{}')
          AND NOTIFY_TIME < TIMESTAMP('{}')
        ORDER BY
          NOTIFY_TIME ASC
    """
    rows = bqclient.query(querystr.format(
        jitter,
        args.startTime,
        args.endTime
    ))
    
    # create one Pub/Sub norification topic for each type of event
    publisher = pubsub.PublisherClient()
    topics = {}
    for event_type in ['wheelsoff', 'arrived', 'departed']:
        topics[event_type] = publisher.topic_path(args.project, event_type)
        try:
            publisher.get_topic(topics[event_type])
        except:
            publisher.create_topic(topics[event_type])

    programStartTime = datetime.datetime.utcnow()
    simStartTime = datetime.datetime.strptime(args.startTime, TIME_FORMAT).replace(tzinfo=pytz.UTC)
    notify(publisher, topics, rows, simStartTime, programStartTime, args.speedFactor)

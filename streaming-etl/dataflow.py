with beam.Pipeline('DirectRunner') as pipeline:
    
    airports = (pipeline
        | beam.io.ReadFromText('airports.csv.gz')
        | beam.Map(lambda line: next(csv.reader([line])))
        | beam.Map(lambda fields: (fields[0], (fields[21], fields[26])))
    )

    airports | beam.Map(lambda (airport, data):
            '{},{}'.fromat(airport, ','.join(data)))
        | beam.io.textio.WriteToText('extracted_airports')

    pipeline.run()


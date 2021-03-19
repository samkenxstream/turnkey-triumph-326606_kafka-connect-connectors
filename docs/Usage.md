# Usage

## Set up Kafka Connect to use `kafka backup and restore`

Kafka Connect is shipped only with a small number of connectors. All other connectors are added by putting the connector `jar` file in the plugin.path destination.

### Local environment

See [Build and Run](Quick_Start.md).

### PROD environment using curl

```sh
curl -X POST -H "Content-Type: application/json" \
  --data "@path/s3-sink.properties"
  http://connect.server:8083/connectors
```

## Backup

Configure a Kafka connect Sink Connector
(e.g. create a file `s3-sink.properties`):

```
name=sinkbackup
connector.class=com.instaclustr.kafka.connect.s3.sink.AwsStorageSinkConnector
tasks.max=1
prefix=databackup
topics.regex=.*
aws.s3.bucket=bugcrowd-msk-development-evangelia-backup
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter  
```

### Configuration options

| Name                        | Required? | Recommended Value                                    | Comment                                                                                                |
|-----------------------------|-----------|------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `name`                      | ✓         | `backup-sink`                                          | A unique name identifying this connector jobs                                                          |
| `connector.class`           | ✓         | `com.instaclustr.kafka.connect.s3.sink.AwsStorageSinkConnector`      | Must be this class to use `kafka-connect`                                              |
| `tasks.max`                 | ✓         | 5                                                    | Number of threads for backup. Set number kafka topic partation                                        |
| `topics`                    | -         |                                                      | Explicit, comma-separated list of topics to back up                                                    |
| `topics.regex`              | -         | `.*`                                                  | Topic regex to back up                                                                                |
| `key.converter`             | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                      |
| `value.converter`           | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                      |
| `prefix`                    | -         | ``                                                   | The path prefix to the location the s3 objects must be put                                                       |
| `aws.s3.bucket`             | ✓         | ``                                     | S3 bucket to be written to.                                  |

NOTE : use either `topics` or `topics.regex`.Sink connector must set any one of option. [ref](https://kafka.apache.org/documentation/#connect_rest)

## Restore

Configure a Kafka connect Source Connector
(e.g. create a file `s3-source.properties`):

```
name=restore202103042141
prefix=databackup/202103042137
connector.class=com.instaclustr.kafka.connect.s3.source.AwsStorageSourceConnector
tasks.max=2
aws.region = us-east-1
topics.regex=.*
aws.s3.bucket=bugcrowd-msk-development-evangelia-backup
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter

```

### Configuration Options

| Name                        | Required? | Recommended Value                                    | Comment                                                                                                |
|-----------------------------|-----------|------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `name`                      | ✓         | `restore-source`                                       | A unique name identifying this connector jobs                                                        |
| `connector.class`           | ✓         | `com.instaclustr.kafka.connect.s3.sink.AwsStorageSourceConnector`      | Must be this class to use `kafka-connect`                                            |
| `tasks.max`                 | ✓         | 5                                                    | Number of threads for restore. Set number kafka topic partation                                        |
| `s3.topics   `              | -         | `.*`                                                  | Specify the required topics to process found in an S3 bucket location                                 |
| `key.converter`             | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                  |
| `value.converter`           | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                  |
| `prefix`                    | -         | ``                                                   | The path prefix to the location the s3 objects must be read from                                       |
| `aws.s3.bucket`             | ✓         | ``                                                   | S3 bucket to be written to                                                                            |
| `maxRecordsPerSecond`       | -         | ``                                                    | The rate of records being produced to kafka. Will help with tuning it according to the capability of a worker   |
| `kafka.topicPrefix`         | -         | ``                                                   | Specify a prefix for the kafka topic written to                                                         |

### Monitor the restore progress

* Watch the Kafka Connect log for the message `All records
  read. Restore was successful`
* Currently there is no other direct way to detect when the restore finished.
* Kafka Connect REST API refer to
[CONFLUENT_REST_API](https://docs.confluent.io/current/connect/references/restapi.html) and 
[APACHE_REST_API](https://kafka.apache.org/documentation/#connect_rest)

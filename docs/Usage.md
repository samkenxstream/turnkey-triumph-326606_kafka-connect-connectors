# Usage

## Set-up Kafka Connect for Using Kafka Backup - Restore

Kafka Connect is shipped only with a small number of connectors. All other connectors are added by including the connector `jar` file in the plugin.path destination.

### Local Environment

See [Build and Run](Quick_Start.md).

### PROD Environment Using CURL

```sh
curl -X POST -H "Content-Type: application/json" \
  --data "@path/s3-sink.properties"
  http://connect.server:8083/connectors
```

## Backup

Configure a Kafka connect Sink Connector
(example create a file `s3-sink.properties`):

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

### Backup Configuration Options

| Name                        | Required? | Recommended Value                                    | Comment                                                                                                |
|-----------------------------|-----------|------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `name`                      | ✓         | `backup-sink`                                          | Unique name that identifie the connector jobs                                                          |
| `connector.class`           | ✓         | `com.instaclustr.kafka.connect.s3.sink.AwsStorageSinkConnector`      | Class to use `kafka-connect`                                              |
| `tasks.max`                 | ✓         | 5                                                    | Number of threads for backup. Set number kafka topic partation                                        |
| `topics`                    | -         |                                                      | Explicit, comma-separated list of topics to back up                                                    |
| `topics.regex`              | -         | `.*`                                                  | Topic regex to back up                                                                                |
| `key.converter`             | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Class to interpret the data as bytes.                                                      |
| `value.converter`           | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Class to interpret the data as bytes.                                                      |
| `prefix`                    | -         | ``                                                   | Path prefix to the location, where the s3 objects must be included                                                       |
| `aws.s3.bucket`             | ✓         | ``                                     | S3 bucket name to write the data.                                  |

Note : Use either `topics` or `topics.regex`.Sink connector must set to any one of option. [See ref](https://kafka.apache.org/documentation/#connect_rest)

## Restore

Configure a Kafka connect Source Connector
(example create a file `s3-source.properties`):

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

### Restore Configuration Options

| Name                        | Required? | Recommended Value                                    | Comment                                                                                                |
|-----------------------------|-----------|------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `name`                      | ✓         | `restore-source`                                       | Unique name that identifies the connector jobs                                                        |
| `connector.class`           | ✓         | `com.instaclustr.kafka.connect.s3.sink.AwsStorageSourceConnector`      | Class to use `kafka-connect`                                            |
| `tasks.max`                 | ✓         | 5                                                    | Number of threads for restore.Set the number of kafka topic partiations                                     |
| `s3.topics   `              | -         | `.*`                                                  | Specify the required topics to process, found in an S3 bucket location                                 |
| `key.converter`             | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Class to interpret the data as bytes                                                  |
| `value.converter`           | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Class to interpret the data as bytes                                                  |
| `prefix`                    | -         | ``                                                   | Path prefix to the location from where s3 objects must be read.                                      |
| `aws.s3.bucket`             | ✓         | ``                                                   | S3 bucket to be written to                                                                            |
| `maxRecordsPerSecond`       | -         | ``                                                    | Rate of records being produced to Kafka. Will help with tuning it according to the capability of a worker.   |
| `kafka.topicPrefix`         | -         | ``                                                   | Specify a prefix for the kafka topic that is written to.                                                         |

### Monitor Restore Progress

* Watch the Kafka Connect log for following the message:- `All records
  read. Restore was successful`
* Currently, there is no other direct way to detect when the restore finished.
* Kafka Connect REST API refer to
[CONFLUENT_REST_API](https://docs.confluent.io/current/connect/references/restapi.html) and 
[APACHE_REST_API](https://kafka.apache.org/documentation/#connect_rest)

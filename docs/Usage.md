# Usage

## Set up Kafka Connect to use `kafka backup and restore`

Kafka Connect is shipped only with a small number of connectors. All other connectors are added by putting the connector `jar` file in the plugin.path destination.

### Local environment

See [Build and Run](Quick_Start.md).

## Backup

Configure a Backup Sink Connector
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
| `tasks.max`                 | ✓         | 5                                                    | Number of threads for backups. Set number kafka topic partation                                        |
| `topics`                    | -         |                                                      | Explicit, comma-separated list of topics to back up                                                    |
| `topics.regex`              | -         | `.*`                                                  | Topic regex to back up                                                                                |
| `key.converter`             | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                      |
| `value.converter`           | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                                      |
| `prefix`                    | ✓         | ``                                                   | The path prefix to the location the s3 objects must be put                                                       |
| `aws.s3.bucket`             | ✓         | ``                                     | S3 bucket to be written to.                                  |

### Enable the Backup Sink

Configure the Sink Connector.

**Using curl:**

```sh
curl -X POST -H "Content-Type: application/json" \
  --data "@path/to/connect-backup-sink.properties"
  http://my.connect.server:8083/connectors
```

**Using [Confluent CLI](https://docs.confluent.io/current/cli/index.html):**

```sh
confluent load backup-source -d path/to/connect-backup-sink.properties
```

### Monitor the progress

* Watch Kafka Connect logs (e.g. `confluent log connect`)
* Watch the consumer lag for the sink connector. The consumer group is
  probably named `connect-backup-sink`. Use for example
  `kafka-consumer-groups --bootstrap-server localhost:9092 --describe
  --group connect-backup-sink` to monitor it.

## Restore

Configure a Backup Source Connector
(e.g. create a file `connect-backup-source.properties`):

```
name=backup-source
connector.class=de.azapps.kafkabackup.source.BackupSourceConnector
tasks.max=1
topics=topic1,topic2,topic3
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
header.converter=org.apache.kafka.connect.converters.ByteArrayConverter
source.dir=/my/backup/dir
batch.size=500
```

### Configuration Options

| Name              | Required? | Recommended Value                                    | Comment                                                                          |
|-------------------|-----------|------------------------------------------------------|----------------------------------------------------------------------------------|
| `name`            | ✓         | `backup-source`                                      | A unique name identifying this connector jobs                                    |
| `connector.class` | ✓         | `de.azapps.kafkabackup.source.BackupSourceConnector` | Must be this class to use `kafka-backup`                                         |
| `tasks.max`       | ✓         | 1                                                    | Must be `1`. Currently no support for multi-task backups                         |
| `topics`          | ✓         | `topic1,topic2,topic3`                               | A list of topics to restore. Only explicit list of topics is currently supported. Rename existing folder on disk to restore to a different topic. |
| `key.converter`   | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                |
| `value.converter` | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                |
| `header.converter` | ✓         | `org.apache.kafka.connect.converters.ByteArrayConverter` | Must be this class to interpret the data as bytes                                |
| `source.dir`      | ✓         | `/my/backup/dir`                                     | Location of the backup files.                                                    |
| `batch.size`      | -         | `500`                                                | How many messages should be processed in one batch?                                                                                 |
| `cluster.*`                 | -         | none                                                 | Other producer configuration options required to connect to the cluster (e.g. SSL settings, serialization settings, etc)            |

### Monitor the restore progress

* Watch the Kafka Connect log for the message `All records
  read. Restore was successful`
* Currently there is no other direct way to detect when the restore finished.

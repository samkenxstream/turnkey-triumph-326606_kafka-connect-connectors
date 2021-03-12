# Kafka Backup: Architecture

## Connectors

Kafka Backup consists of two Kafka Connect Connectors: A sink connector responsible for the backup task and a source connector responsible for the restoration.

The Kafka Connect Architecture distinguishes between Connectors and Tasks: 
Tasks perform the actual work and the Connector acts as a preparation and cleanup stage and configures the actual Tasks. For performance reasons, Kafka Connect supports multiple tasks per connector and distributes them across multiple Kafka Connect workers if available.

### Sink Task

Sink Task extends the Kafka Connect `SinkTask`. There are two jobs, the sink task is responsible for: 

First, every time, Kafka Connect delivers new Records to be backed up, the task write files to the appropriate topic and partition folder in S3. The object key would be defined as below

```user-defined-prefix/<topic>/<partition>/<start offset>-<end offset> ```

Second, the Sink Task is also responsible for backing up the consumer group offsets. Ideally this job would be scheduled independently of the delivery of new messages from Kafka Connect. Currently the offsets are synchronized every time, new records are pushed to Kafka Connect. Note, that the sync of consumer offsets is not supported out of the box in Kafka Connect. Thus we need to create our own `AdminClient` that is responsible for fetching the offsets for all consumer groups.
The object key would be defined as below

```user-defined-prefix/<topic>/<partition>/offset/consumers_offset ```

Note, consumers_offset always latest with all consumer group offset. [below](#offset) is sample exmple.

### Source Task

Source Task extends the Kafka Connect `SourceTask`. There are two jobs, the source task is responsible for: 

First, reading data from an S3 bucket and write back into kafka topics. 
The restore task, splits the incoming data in configurable batches and performs the restore for each batch one after another. As there is no way to gracefully shut down Kafka Connect from the inside, the Source Task logs a completion message every few seconds after all data is restored from the files.

NOTE : When reading data from an S3 bucket the source connector expects to have a kafka topic with the same name and partitions in the target kafka cluster.

Second, Offset transformation logic given below. 
    1) Initialize all consumer offset to 0
    2) Process only consumer group offset > lastReadOffset
    3) consumerGroupOffset = offset > totalRecords ? totalRecords : offset
`syncGroupForOffset` this function is called for every record that is written to Kafka. calulate `consumerGroupOffset` and commit this offset for the appropriate consumer group.

### Offset

The offset file consists of a mapping from consumer groups to the committed offset in the current topic and partition S3 folder . It is represented as a simple JSON map where the map key is the consumer group and the value is the offset.

Example:

```json
{
  "consumer-group1": 100,
  "consumer-group2": 200,
  "consumer-group3": 300,
  "consumer-group4": 300
}
```

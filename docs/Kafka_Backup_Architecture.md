# Kafka Backup: Architecture

## Connectors

Kafka Backup consists of two Kafka Connect Connectors: 
* sink connector for the backup task 
* source connector for the restore task

The Kafka Connect Architecture distinguishes between Connectors and Tasks:- 
Tasks perform the actual work and the Connector acts as a preparation and cleanup stage and configures the actual tasks. For performance reasons, Kafka Connect supports multiple tasks per connector and distributes them across multiple Kafka Connect workers if available.

### Sink Task

Sink task extends the Kafka Connect `SinkTask`.sink task is responsible for the following jobs:-

Every time,Kafka Connect delivers new Records to be backed up, the task write files to the appropriate topic and partition folder in S3. The object key defined as:

```user-defined-prefix/<topic>/<partition>/<start offset>-<end offset> ```

The Sink task is responsible for backing up the consumer group offsets. Ideally this job will be scheduled independent of the delivery of new messages from Kafka Connect. Currently the offsets are synchronized every time, new records are pushed to Kafka Connect. 
Note:- The sync of consumer offsets is not supported out of the box in Kafka Connect. Thus we need to create our own `AdminClient` that is responsible for fetching the offsets for all consumer groups.
The object key will defined as:

```user-defined-prefix/<topic>/<partition>/offset/consumers_offset ```

Note:- consumers_offset always latest with all consumer group offset.[below](#offset) is sample exmple is:

### Source Task

Source task extends the Kafka Connect `SourceTask`. The source task is responsible for the following jobs:

Reading data from an S3 bucket and write back into Kafka topics. 
The restore task, splits the incoming data in configurable batches and performs the restore for each batch one after another.Since there is no way to gracefully shut down Kafka Connect from the inside, the Source task logs a completion message every few seconds after all the data is restored from the files.

NOTE : When reading data from an S3 bucket the source connector expects to have a kafka topic with the same name and partitions in the target kafka cluster.

Second, Offset transformation logic given below.

* Initialize all consumer offset to 0
* Process only consumer group offset > lastReadOffset    
* consumerGroupOffset = offset > totalRecords ? totalRecords : offset
   `syncGroupForOffset` this function is called for every record that is written to Kafka.Calulate `consumerGroupOffset` and commit this offset for the     appropriate consumer group.

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

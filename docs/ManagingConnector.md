# Managing Kafka Connector

## Standalone vs. Distributed Mode

Kafka Connectors and tasks are logical units of *work* and run as processes. The process is called a **worker** in Kafka Connect.
There are two modes for running workers:- *standalone mode* and *distributed mode*. Before getting started identify the mode that works best for your environment 

**Standalone mode** is useful for development, proof-of-concept and testing Kafka Connect on a local Kafka stack. It can also be used for environments that typically use single agents (for example, sending web server logs to Kafka).

**Distributed mode** runs Connect workers on multiple machines (nodes). These form a Connect cluster. Kafka Connect distributes running connectors across the cluster. You can add more nodes or remove nodes based on your requirement.

Distributed mode is also more fault tolerant. If a node unexpectedly leaves the cluster, Kafka Connect automatically distributes the work of that node to other nodes in the cluster. Since Kafka Connect stores connector configurations, status, and offset information inside the Kafka cluster where it is safely replicated, losing the node (where a Connect worker runs) does not result in any.

### Standalone Mode

When testing the connector in standalone mode, use the following syntax:

```sh
KAFKA_HOME>./bin/connect-standalone.sh config/connect-standalone.properties config/s3-sink.properties
```

where,
* `connect-standalone.properties` is used to configure worker tasks 
* `s3-sink.properties or s3-source.properties` is used to configure the connector itself.

> **Note:**  Worker tasks configurations ( `connect-standalone.properties` or `connect-distributed.properties`) and connector configurations (`s3-sink.properties` or `s3-source.properties`)
use different configuration parameters, mainly because the first set is configuring Kafka access and the second set is configuring Kafka connect execution. Do not mix parameters from different configuration files for **standalone process**.

Configurations for sink and source connectors (`s3-sink.properties` and `s3-source.properties`) also differ. Some of the sink connector parameters are not recognized by source connector and vice versa.

When you start a connector (sink or source), it should have its own dedicated port set with `rest.port` parameter. You can not use the same `connect-standalone.properties` file for different connectors running simultaneously. It is not required, but recommended to have separate configuration files named `connect-standalone-backup.properties` and `connect-standalone-restore.properties` with preset port values, such as sink `bootstrap.servers=localhost:9094` and source `bootstrap.servers=localhost:9096`.

After the **Standalone process** is started, you can check the connector activities either in the terminal output or in the log files (`KAFKA_HOME/logs/connect.log`.

### REST API for Managinge Connectors

By default, Kafka Connect is listening on port 8083, The following are the, available REST syntax examples that uses bootstrap server IP as 127.0.0.1 :-

#### GET /connectors
Check the available connectors:

```sh
curl -X GET -H "Accept: application/json" http://127.0.0.1:8083/connectors
#response
["kafka-backup-20210315101010", "kafka-backup-20210316101010"]
```

#### POST /connectors
Create a new connector (connector object is returned):

```sh
curl http://kafka-connect-evangelia-backup:8083/connectors -X POST -H 'Content-Type: application/json' -d '{
   "name":"kafka-backup-20210317101010",
   "config":{
      "connector.class":"com.instaclustr.kafka.connect.s3.sink.AwsStorageSinkConnector",
      "tasks.max":"1",
      "topics.regex":".*",
      "prefix":"data",
      "aws.s3.bucket":"bugcrowd-msk-development-evangelia-backup",
      "value.converter":"org.apache.kafka.connect.converters.ByteArrayConverter",
      "key.converter":"org.apache.kafka.connect.converters.ByteArrayConverter"
   }
}'
```

#### GET /connectors/(string:name)
Get information about an existing connector (connector object is returned):

```sh
curl -X GET -H "Accept: application/json" http://127.0.0.1:8083/connectors/kafka-backup-20210317101010
#response
{
   "name":"kafka-backup-20210317101010",
   "config":{
      "name":"kafka-backup-20210317101010",
      "connector.class":"com.instaclustr.kafka.connect.s3.sink.AwsStorageSinkConnector",
      "tasks.max":"1",
      "topics.regex":".*",
      "prefix":"data",
      "aws.s3.bucket":"bugcrowd-msk-development-evangelia-backup",
      "value.converter":"org.apache.kafka.connect.converters.ByteArrayConverter",
      "key.converter":"org.apache.kafka.connect.converters.ByteArrayConverter"
   },
   "tasks":[{"connector":"kafka-backup-20210317101010","task":0}],
   "type":"sink"
}
```
#### DELETE /connectors/(string:name)
Stops connector's tasks, deletes the connector and its configuration

```sh
curl -X DELETE http://127.0.0.1:8083/connectors/kafka-backup-20210317101010
#no response/ 204 No Content
```

For more considerations on using Kafka Connect REST API refer to
[CONFLUENT_REST_API](https://docs.confluent.io/current/connect/references/restapi.html)


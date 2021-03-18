# Kafka Backup and Restore

Kafka Backup is a tool to back up and restore your Kafka data including consumer group offsets. Kafka Backup is the only viable solution to take a cold backup of Kafka data and restore
it correctly.

It is designed as two connectors for Kafka Connect: 
* Sink connector (backing data and consumers group offset) 
* Source connector (restoring data and consumers group offset) 

## Features

* Backup and restore topic data
* Backup and restore consumer-group offsets
* Supports only backup/restore to/from S3

# Prerequisites

The following are required to run the Kafka Connect

* Java 1.8
* [Apache Maven](https://maven.apache.org/install.html)
* [kafkacat](https://github.com/edenhill/kafkacat)
* Create folders ~/kafka , ~/kafka/plugins and /ect/kafka. Provide full permssion 
* [AWS your Account Setup](https://bugcrowd.atlassian.net/wiki/spaces/DEV/pages/80445478/AWS+your+Account+Setup). Make sure S3 bucket has access.

# Getting Started

* Download [from GitHub](https://github.com/bugcrowd/kafka-connect-connectors) and unzip it.
* Just run `mvn clean compile package -DskipTests=true` in the root directory of Kafka Backup. You will find `target/kafka-connect-instaclustr-0.1.3-uber.jar` jar file. 
* Copy jar file from `target` to `~/kafka/plugin` using CLI `cp target/kafka-connect-instaclustr-0.1.3-uber.jar ~/kafka/plugins`
* go to `bin` directory 

* Create and Start Kafka Backup, Kafka Restore Docker alnog with Kafka connect standalone.
```sh
./setup.sh
```
* Start Kafka Backup,Consumers,Scnario-1 data set insjection and Export offsets to verify from backup and restore. 
```sh
shellscripts/scenario_1.sh
```
you can verify scenario-1 kafka topic data and offset backup in S3(`$bucket/databackup/datetime`). 
once verified,replace tumbstone message with value by executing the scnario-2 

```sh
shellscripts/scenario_2.sh
```
you can verify scenario-2 kafka topic data and offset backup in S3(`$bucket/databackup/datetime`). 

* Restore data scenario 1 & 2 by providing one by one S3 folder
```sh
shellscripts/restore-standalone.sh {Foldername `databackup/datetime`}
```

## More Documentation

* [ManagingConnector](ManagingConnector.md)
* [Architecture](Kafka_Backup_Architecture.md)
* [Connector](https://www.instaclustr.com/support/documentation/kafka-connect/pre-built-kafka-connect-plugins/)

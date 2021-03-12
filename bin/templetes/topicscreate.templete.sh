#!/bin/bash
cd ~/kafka

# create topic in kafka backup cluster. cleanup.policy=compact and delete
bin/kafka-topics.sh --create --bootstrap-server 127.0.0.1:9094 --topic "crowdcontrol_development.public.users" --partitions 1 --replication-factor 1 --config cleanup.policy=compact --config delete.retention.ms=20000 --config min.compaction.lag.ms=20000 --config max.compaction.lag.ms=40000 --config min.cleanable.dirty.ratio=0.01
bin/kafka-topics.sh --create --bootstrap-server 127.0.0.1:9094 --topic "crowdcontrol_development.public.identities" --partitions 1 --replication-factor 1 --config cleanup.policy=delete --config delete.retention.ms=2000 --config retention.ms=2000 

# # create topic in kafka restore cluster.cleanup.policy=compact and delete
bin/kafka-topics.sh --create --bootstrap-server 127.0.0.1:9096 --topic "crowdcontrol_development.public.users" --partitions 1 --replication-factor 1 
bin/kafka-topics.sh --create --bootstrap-server 127.0.0.1:9096 --topic "crowdcontrol_development.public.identities" --partitions 1 --replication-factor 1 

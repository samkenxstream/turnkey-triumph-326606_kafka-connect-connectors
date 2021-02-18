#!/bin/bash
cp connect-standalone-backup.properties ~/kafka/config/connect-standalone.properties
cp connect-distributed-backup.properties /etc/kafka/connect-distributed.properties
now=`date +"%Y-%m-%d-%H:%M:%S"`

sed -e "s/databackup/databackup\/${now}/g" -e "s/sinkbackup/sink`date +"%Y%m%d%H%M"`/g" s3-sink.properties > ~/kafka/config/s3-sink.properties

cd ~/kafka/

bin/connect-standalone.sh config/connect-standalone.properties config/s3-sink.properties

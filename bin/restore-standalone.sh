#!/bin/bash

cp connect-standalone-restore.properties ~/kafka/config/connect-standalone.properties
cp connect-distributed-restore.properties /etc/kafka/connect-distributed.properties 

CONNECTOR_CONFIG="s3-source.properties"
cat <<EOF >"$CONNECTOR_CONFIG"
name=restore`date +"%Y%m%d%H%M"`
prefix=$1
connector.class=com.instaclustr.kafka.connect.s3.source.AwsStorageSourceConnector
tasks.max=2
aws.region = us-east-1
topics.regex=.*
aws.s3.bucket=bugcrowd-msk-development-evangelia-backup
value.converter=org.apache.kafka.connect.converters.ByteArrayConverter
key.converter=org.apache.kafka.connect.converters.ByteArrayConverter
EOF

cp $CONNECTOR_CONFIG ~/kafka/config/
cd ~/kafka/

bin/connect-standalone.sh config/connect-standalone.properties config/s3-source.properties

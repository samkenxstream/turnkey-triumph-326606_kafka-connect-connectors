#!/bin/sh

aws s3 cp /usr/src/kafka-connect-connectors/target/kafka-connect-instaclustr-0.1.3-uber.jar s3://$AWS_BUCKET/


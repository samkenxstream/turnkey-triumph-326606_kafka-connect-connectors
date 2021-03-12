#!/bin/bash
cp properties/connect-standalone-backup.properties ~/kafka/config/connect-standalone.properties
cp properties/connect-distributed-backup.properties /etc/kafka/connect-distributed.properties
# now=`date +"%Y%m%d%H%M"`
# echo ${1}
# kill $(${2}/backuppid)
sed -e "s/databackup/databackup\/${1}/g" -e "s/sinkbackup/sink${1}/g" connectorproperty/s3-sink.properties > ~/kafka/config/s3-sink.properties

cd ~/kafka/
# echo ${2}
nohup bin/connect-standalone.sh config/connect-standalone.properties config/s3-sink.properties > /dev/null & 
echo $! > ${2}/backuppid 
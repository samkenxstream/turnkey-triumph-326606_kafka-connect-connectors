#!/bin/bash

echo "
SETTING UP FOLLOWING STEPS:
1. Delete if kafka-connect dockers (backup and restore) are exists.
2. Modify the scripts based on the ports for kafka clusters kafkabackup and kafkarestore which are passed as parameter.
   if parameter is empty then default ports kafkabackup:9094 and kafkarestore:9096 are consider.
3. Create kafka clusters 'kafkabackup and kafkarestore' docker (lable = kafka-connect). 
4. Fetch the kafka from apache repo. Setup for kafka connect standalone.
5. Fetch kafka-connect-connectors from repo. Build the project and copy to plugin folder.
6. Create topics Users and Identities in backup and restore kafka cluster (Docker)
"
sleep 2

backup_port=9094
restore_port=9096
if [ ! -z "$1" ];then
    backup_port=$1
fi

if [ ! -z "$2" ];then
    restore_port=$2
fi

connect=$(docker ps -a -q --filter "label=kafka-connect")
if [  "${connect}" ]; then
    docker stop $(docker ps -a -q --filter "label=kafka-connect") 
    docker rm $(docker ps -a -q --filter "label=kafka-connect")
fi
default_backup_port=9094
default_restore_port=9096
currentpath=$(pwd)

sed "s/${default_backup_port}/${backup_port}/g" templetes/docker-compose-backup.templete.yml > docker/docker-compose-backup.yml
sed "s/${default_restore_port}/${restore_port}/g" templetes/docker-compose-restore.templete.yml > docker/docker-compose-restore.yml

sed -e "s/${default_backup_port}/${backup_port}/g" -e "s/${default_restore_port}/${restore_port}/g" templetes/topicscreate.templete.sh > topicscripts/topicscreate.sh
sed -e "s/${default_backup_port}/${backup_port}/g" -e "s/${default_restore_port}/${restore_port}/g" templetes/datagenarator.templete.sh > shellscripts/datagenarator.sh

sed "s/${default_backup_port}/${backup_port}/g" templetes/connect-distributed.templete.properties > properties/connect-distributed-backup.properties
sed "s/${default_backup_port}/${restore_port}/g" templetes/connect-distributed.templete.properties > properties/connect-distributed-restore.properties

pluginPath=${HOME}/kafka/plugins
echo "plugin.path=$pluginPath" >> templetes/connect-standalone.templete.properties

sed "s/${default_backup_port}/${backup_port}/g" templetes/connect-standalone.templete.properties > properties/connect-standalone-backup.properties
sed "s/${default_backup_port}/${restore_port}/g" templetes/connect-standalone.templete.properties > properties/connect-standalone-restore.properties
sleep 5
docker-compose -f docker/docker-compose-backup.yml -p kafkabackup up -d
docker-compose -f docker/docker-compose-restore.yml -p kafkarestore up -d

cp -r topicscripts ~/kafka/

cd ~/kafka
# curl "https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz" -o ~/kafka/kafka.tgz
tar -xvzf ~/kafka/kafka.tgz --strip 1
chmod -R 0777 ~/kafka/

cd ~/kafka/topicscripts

./topicscreate.sh
echo ""
echo "Completed setting up kafka backup,restore and connect standalone cluster "

#!/bin/bash

echo "\nSETTING UP FOLLOWING STEPS:
1. Delete if kafka-connect dockers (backup and restore) are exists.
2. Modify the scripts based on the ports for kafka clusters kafkabackup and kafkarestore which are passed as parameter.
   Default ports for kafkabackup:9094 and kafkarestore:9096 are consider if parameter is empty.  
3. Create kafka clusters 'kafkabackup and kafkarestore' docker (lable = kafka-connect). 
4. Fetch the kafka from apache repo. Setup for kafka connect standalone.
5. Fetch kafka-connect-connectors from repo. Build the project and copy to plugin folder.
6. Create topics Users and Identities in backup and restore kafka cluster (Docker)
7. Genarate Normal and Tombstone data and populated to topics!!!
"
sleep 4

backup_port=9094
restore_port=9096
if [ ! -z "$1" ];then
    backup_port=$1
fi

if [ ! -z "$2" ];then
    restore_port=$2
fi

TARGET_DIR=~/kafka
if [ ! -d $TARGET_DIR ]; then
    mkdir /etc/kafka
    mkdir ~/kafka
    mkdir ~/kafka/plugins  
fi

connect=$(docker ps -a -q --filter "label=kafka-connect")
if [  "${connect}" ]; then
    docker stop $(docker ps -a -q --filter "label=kafka-connect") 
    docker rm $(docker ps -a -q --filter "label=kafka-connect")
fi
default_backup_port=9094
default_restore_port=9096

sed "s/${default_backup_port}/${backup_port}/g" docker-compose-backup.templete.yml > docker/docker-compose-backup.yml
sed "s/${default_restore_port}/${restore_port}/g" docker-compose-restore.templete.yml > docker/docker-compose-restore.yml

sed -e "s/${default_backup_port}/${backup_port}/g" -e "s/${default_restore_port}/${restore_port}/g" topicscripts/TopicCreate.templete.sh > topicscripts/TopicCreate.sh
sed "s/${default_backup_port}/${backup_port}/g" topicscripts/DataGenarator.templete.sh > topicscripts/DataGenarator.sh

sed "s/${default_backup_port}/${backup_port}/g" connect-distributed.templete.properties > connect-distributed-backup.properties
sed "s/${default_backup_port}/${restore_port}/g" connect-distributed.templete.properties > connect-distributed-restore.properties

pluginPath=${HOME}/kafka/plugins
echo "plugin.path=$pluginPath" >> connect-standalone.templete.properties

sed "s/${default_backup_port}/${backup_port}/g" connect-standalone.templete.properties > connect-standalone-backup.properties
sed "s/${default_backup_port}/${restore_port}/g" connect-standalone.templete.properties > connect-standalone-restore.properties

docker-compose -f docker/docker-compose-backup.yml -p kafkabackup up -d
docker-compose -f docker/docker-compose-restore.yml -p kafkarestore up -d

cp -r topicscripts ~/kafka/

cd ~/kafka
curl "https://archive.apache.org/dist/kafka/2.6.0/kafka_2.13-2.6.0.tgz" -o ~/kafka/kafka.tgz
tar -xvzf ~/kafka/kafka.tgz --strip 1

git clone https://github.com/bugcrowd/kafka-connect-connectors.git
cd kafka-connect-connectors
mvn clean package
cp target/distribution-0.1.3-uber.jar ~/kafka/plugins/
sudo cp ~/kafka/config/connect-distributed.properties /etc/kafka/

cd ~/kafka/topicscripts
./TopicCreate.sh
echo "\nTopics Users and Identities are created. There is a wait time of 30 seconds to post both Normal and Tombstone data gets generated and populated to topics!!!\n"
sleep 30
./DataGenarator.sh 

chmod -R 0777 /etc/kafka
chmod -R 0777 ~/kafka/


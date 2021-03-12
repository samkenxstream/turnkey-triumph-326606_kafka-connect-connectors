#!/bin/bash

currentpath=$(pwd)
now=`date +"%Y%m%d%H%M"`
echo "Start Consumers"
shellscripts/consumergroup-set1.sh ${currentpath}/pids
echo "Start kafka backup"
shellscripts/backup-standalone.sh ${now} ${currentpath}/pids
sleep 20
echo "Start data genarator and consumer group offset details"
shellscripts/datagenarator.sh 

sleep 10
kill $(cat ${currentpath}/pids/backuppid)
echo "Backup S3 prefix folder name for set1: databackup/$now. which is used in restore!!!"
sleep 6
shellscripts/groupoffsetdetails.sh $currentpath/"offsetdetails" "offsetdetails-set1"
echo "End data genarator"

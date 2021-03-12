#!/bin/bash

currentpath=$(pwd)

now=`date +"%Y%m%d%H%M"`
shellscripts/consumergroup-set2.sh ${currentpath}/pids

echo "Start data genarator and consumer group offset details"
sleep 2
shellscripts/replaceusermessage.sh
echo "Backup set-2 data"
sleep 10
shellscripts/backup-standalone.sh ${now} ${currentpath}/pids

sleep 20
kill $(cat ${currentpath}/pids/backuppid)
echo "Backup S3 prefix folder name for set2: databackup/$now. which is used in restore!!!"
sleep 6

shellscripts/groupoffsetdetails.sh $currentpath/"offsetdetails" "offsetdetails-set2"
echo "End data genarator"

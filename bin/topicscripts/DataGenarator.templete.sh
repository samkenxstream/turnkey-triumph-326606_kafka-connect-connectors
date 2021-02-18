#!/bin/sh 
 
if [ -z "$1" ];then
    END=100
    else
    END=$1
fi

if [ -f save_user_group_pid.txt ]; then
  kill $(cat save_user_group_pid.txt)
  rm save_user_group_pid.txt

  kill $(cat save_id_group_pid.txt)
  rm save_id_group_pid.txt
fi

nohup kafkacat -b 127.0.0.1:9094 -G user_group crowdcontrol_development.public.users > user_group_output.log &
echo $! > save_user_group_pid.txt

nohup kafkacat -b 127.0.0.1:9094 -G id_group crowdcontrol_development.public.identities > id_group_output.log &
echo $! > save_id_group_pid.txt

for i in $(seq 1 $END);
do

remainder=$(( i % 5 ))
[ "$remainder" -eq 0 ] && cat k_u_null | kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.users -K "\t" -Z
cat k_u_match | kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.users -K "\t" -Z
cat i | kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.identities -K "\t"

done

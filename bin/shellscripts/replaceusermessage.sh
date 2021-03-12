#!/bin/sh 
 
END=20
count=0

for i in $(seq 1 $END);
do
((count=count+1))
tombstones=$(( count % 4))
[ "$tombstones" -eq 0 ] && echo "key-${count}:replacedvalue-${count}"|  kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.users -K ":" -Z
[ "$tombstones" -eq 0 ] && echo "key-${count}:value-${count}"|  kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.identities -K ":"

done

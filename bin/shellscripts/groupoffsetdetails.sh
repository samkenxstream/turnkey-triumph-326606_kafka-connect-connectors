#!/bin/sh 
cd ~/kafka
echo "TOPIC\tGROUP\tCURRENT-OFFSET\tLOG-END-OFFSET\tLAG" > ${1}/${2}.csv
for t in `bin/kafka-consumer-groups.sh  --list --bootstrap-server 127.0.0.1:9094 2>/dev/null`; do
    if [[ $t == "connect"* ]]; then
        continue
    fi
    echo $t | xargs -I {} sh -c "bin/kafka-consumer-groups.sh --bootstrap-server 127.0.0.1:9094 --describe --group {} 2>/dev/null | grep ^{} | awk '{print \$2\"\t\"\$1\"\t\"\$4\"\t\"\$5\"\t\"\$6}' "
    # echo $msg
done >> ${1}/${2}.csv

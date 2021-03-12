#!/bin/bash

nohup kafkacat -C -c20 -b 127.0.0.1:9094 -G usergroup2 crowdcontrol_development.public.users </dev/null &>/dev/null &
echo $! > ${1}/usergroup2

nohup kafkacat -C -c20 -b 127.0.0.1:9094 -G identitiesgroup2 crowdcontrol_development.public.identities > /dev/null & 
echo $! > ${1}/identitiesgroup2
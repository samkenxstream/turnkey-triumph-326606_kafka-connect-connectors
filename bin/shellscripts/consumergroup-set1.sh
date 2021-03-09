#!/bin/bash

nohup kafkacat -C -c10 -b 127.0.0.1:9094 -G usergroup1 crowdcontrol_development.public.users &
echo $! > ${1}/usergroup1
nohup kafkacat -C -c20 -b 127.0.0.1:9094 -G usergroup2 crowdcontrol_development.public.users &
echo $! > ${1}/usergroup2

nohup kafkacat -C -c10 -b 127.0.0.1:9094 -G identitiesgroup1 crowdcontrol_development.public.identities &
echo $! > ${1}/identitiesgroup1
nohup kafkacat -C -c20 -b 127.0.0.1:9094 -G identitiesgroup2 crowdcontrol_development.public.identities &
echo $! > ${1}/identitiesgroup2
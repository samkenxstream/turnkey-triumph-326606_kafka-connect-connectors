cat k_u_match | kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.users -K "\t" -Z
cat i | kafkacat -P -b 127.0.0.1:9094 -t crowdcontrol_development.public.identities -K "\t"

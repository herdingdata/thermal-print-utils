#!/bin/bash
# grab a single message from mqtt and print it
# relies on the following variables being set:
# $MQTT_USER - username for mosquitto
# $MQTT_PASS - password for mosquitto
# $GLOW_DEVICE - the id of the glow IHD. Grab this by subscribing to `-t 'glow/#'
#                you'll see a message with topic 'glow/[redacted]/SENSOR/electricitymeter'
#                the text I've replaced with "[redacted]" is the id you need

# Usage:
# ./print_one_elec.sh

# grab a message (can take ~10s)
export MESSAGE=$(mosquitto_sub -d -t "glow/$GLOW_DEVICE/SENSOR/electricitymeter" -u $MQTT_USER -P $MQTT_PASS -C 1 | grep { | jq)

# get a tempfile
export TEMPFILE=$(mktemp)

# first write the current power consumption, which will be the header
export CURRENT_PWR=$(echo $MESSAGE | jq '.electricitymeter.power.value')
echo "CURRENT ELEC USAGE: $CURRENT_PWR kW" > $TEMPFILE

# do we have free power right now?
if [[ "$CURRENT_PWR" == "0.000" ]]; then
   echo "\n\n\n----------------------------\nZOMG YOU HAVE FREE POWER\n----------------------------\n\n\n\n\n\n" >> $TEMPFILE
fi

# now write the entire json message
echo "$MESSAGE" | grep { | jq >> $TEMPFILE

# print it
./print_txt.sh $TEMPFILE
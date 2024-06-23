#!/bin/bash
# grab a single message from mqtt and print it BUT only if we have 0 power usage right now
# relies on the following variables being set:
# $MQTT_USER - username for mosquitto
# $MQTT_PASS - password for mosquitto
# $GLOW_DEVICE - the id of the glow IHD. Grab this by subscribing to `-t 'glow/#'
#                you'll see a message with topic 'glow/[redacted]/SENSOR/electricitymeter'
#                the text I've replaced with "[redacted]" is the id you need

# Usage:
# source ~/bin/mqtt_creds && ./print_free_power_prompt.sh

# grab a message (can take ~10s)
MESSAGE=$(mosquitto_sub -d -t "glow/$GLOW_DEVICE/SENSOR/electricitymeter" -u $MQTT_USER -P $MQTT_PASS -C 1 | grep { | jq)

# get a tempfile
TEMPFILE=$(mktemp)

# first write the current power consumption, which will be the header
CURRENT_PWR=$(echo $MESSAGE | jq '.electricitymeter.power.value')

# do we have free power right now?
if [[ "$CURRENT_PWR" == "0" ]]; then
    echo $(date) "/print_one_elec_if_free_now.sh: printing a message that we have free power right now"

    # get a tempfile
    TEMPFILE=$(mktemp)

    # put some content in it
    echo "ELEC NOW: $CURRENT_PWR kW" > $TEMPFILE
    echo "\n----------------------------\nZOMG YOU HAVE FREE POWER\n----------------------------\n\n\n\n\n\n-" >> $TEMPFILE
    # optional: now write the entire json message
    # echo "$MESSAGE" >> $TEMPFILE

    # print
    /home/andyrpi/printfun/print_txt.sh $TEMPFILE

else
    # do nothing because we only care about printing something if there's free power now
    echo $(date) "/print_one_elec_if_free_now.sh: no action taken because power consumption now is $CURRENT_PWR kW"
fi



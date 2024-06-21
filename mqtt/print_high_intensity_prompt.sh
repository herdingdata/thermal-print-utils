#!/bin/bash
# Our goal here is to provide a prompt that we're using a lot of power
# in a time of day where the grid is particularly intensive.
# This is so that we can have a call to action to reduce usage.

# Uses two sources:
# 1. api.carbonintensity.org.uk
# 2. Our MQTT elec messages as per print_elec_now.sh and print_free_power_prompt.sh

# relies on the following variables being set:
# $POSTCODE - The postcode for the area we care about. Only first part should be provided (3-4 letters, e.g. "NW1")
# $MQTT_USER - username for mosquitto
# $MQTT_PASS - password for mosquitto
# $GLOW_DEVICE - the id of the glow IHD. Grab this by subscribing to `-t 'glow/#'
#                you'll see a message with topic 'glow/[redacted]/SENSOR/electricitymeter'
#                the text I've replaced with "[redacted]" is the id you need

# Usage:
# source ~/bin/mqtt_creds && ./print_high_intensity_prompt.sh

# Grab a message with our current usage (can take ~10s)
MESSAGE=$(mosquitto_sub -d -t "glow/$GLOW_DEVICE/SENSOR/electricitymeter" -u $MQTT_USER -P $MQTT_PASS -C 1 | grep { | jq)
# first extract the current power consumption, which will be the header
CURRENT_PWR=$(echo $MESSAGE | jq '.electricitymeter.power.value')

# get a tempfile
TEMPFILE=$(mktemp)

# threshold is in kW - if below then let's exit because we're not using enough to bother with a prompt
if (( $(echo "$CURRENT_PWR < 0.5" | bc -l) )); then
  echo $(date) "/print_high_intensity_prompt.sh: current power consumption is below threshold, exiting"
  exit 1
else
  echo $(date) "/print_high_intensity_prompt.sh: current power consumption is greater than threshold, checking intensity"
fi

# Grab current carbon intensity forecast
DATETIME=$(date '+%Y-%m-%dT%H:%MZ')
INTENSITY=$(curl https://api.carbonintensity.org.uk/regional/intensity/${DATETIME}/fw24h/postcode/${POSTCODE} | jq)
# extract just the relevant bits and only for the next few hours. First line is now.
# Fields "time,intensity_integer,intensity_text"
FORECAST=$(echo "$INTENSITY" | jq -r '.data.data[] | (.from | strptime("%Y-%m-%dT%H:%MZ") | strftime("%H:%M") ) + "," + .intensity.index' | head -12)
# I took out + "," + (.intensity.forecast|tostring)

# is it really intensive right now?
TEXT_INTENSITY_NOW=$(echo "$FORECAST" | head -1 | awk -F "\"*,\"*" '{print $2}')
if [[ "$TEXT_INTENSITY_NOW" == "moderate" ]] || [[ "$TEXT_INTENSITY_NOW" == "high" ]] || [[ "$TEXT_INTENSITY_NOW" == "very high" ]]; then
    echo $(date) "/print_high_intensity_prompt.sh: printing a message that we should reduce our power right now"

    # get a tempfile
    TEMPFILE=$(mktemp)

    # put some content in it
    echo "USE LESS ENERGY NOW IF POSS" > $TEMPFILE
    echo "Elec now: $CURRENT_PWR kW" >> $TEMPFILE
    echo "Grid carbon now: $TEXT_INTENSITY_NOW" >> $TEMPFILE
    echo "\n6hr intensity forecast: \n" >> $TEMPFILE
    echo "    time ,intensity" >> $TEMPFILE
    echo "$(echo $FORECAST | sed -e 's/^/    /')" >> $TEMPFILE

    # print
    /home/andyrpi/printfun/print_txt.sh $TEMPFILE

else
    # do nothing because we only care about printing something if there's free power now
    echo $(date) "/print_high_intensity_prompt.sh: no action taken because power intensity now is $TEXT_INTENSITY_NOW"
fi



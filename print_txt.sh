#!/bin/bash
# adds a date as the first line. Pads hashes around line 1 to be a title. Wrap the text. Print it all.

# Usage:
# ./print_txt.sh filepath

export DT=$(date '+%Y-%m-%d %H:%M:%S')

# read the file and wrap to 28chars (80mm paper)
export TEXT_START=$(cat $@ | fmt -w 28 -s)

# add our header emphasis
export TEXT_PROCESSED=$(printf "$DT\n\n$TEXT_START" | sed '3i############################' | sed '5i############################\n')

# show the user what we've parsed
echo "$TEXT_PROCESSED"

# print it
echo "$TEXT_PROCESSED" | lp -s

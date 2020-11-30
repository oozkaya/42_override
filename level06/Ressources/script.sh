#!/bin/bash

(( echo "ABCDEF" ; echo "6231554"; cat ) | ./level06 ) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level07/.pass)\n"
EOI
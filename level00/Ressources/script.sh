#!/bin/bash

GETPASS="cat /home/users/level01/.pass"

function hexToDec {
    echo $((16#$1))
}

hexToDec "149c" > /tmp/exploit00

(set -x; cat /tmp/exploit00 - | ~/level00) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$($GETPASS)\n"
EOI

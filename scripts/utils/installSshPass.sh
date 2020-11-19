#! /bin/bash

CURDIR=`dirname $0`

function detectOS {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

        if [[ ${DISTRIB} = "Ubuntu"* ]] || [[ ${DISTRIB} = "Debian"* ]]; then
            sudo apt install sshpass -y 
        fi
        if [[ ${DISTRIB} = "CentOS"* ]] || [[ ${DISTRIB} = "Fedora"* ]]; then
            sudo yum install sshpass -y
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
    else
        echo "Please install manually sshpass"
    fi
}

read -p "Do you want install sshpass ? [yY] " -n 1 -r
if [[ $REPLY =~ ^[yY]$ ]]; then
    echo
    selectBridgedInterface
fi

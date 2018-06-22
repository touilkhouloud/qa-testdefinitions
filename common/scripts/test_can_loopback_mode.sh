#!/bin/sh

if [ ! -e /sys/class/net/can0 ];then
        lava-test-case canconfig_can0 --result skip
        lava-test-case start_can0 --result skip
        lava-test-case send_frames_through_can0 --result skip
        lava-test-case receive_frames_through_can0 --result skip
        lava-test-case stop_can0 --result skip
        exit 0
fi
sleep 2
#config the can interfaces
canconfig can0 bitrate 50000 ctrlmode loopback on
sleep 2
if [ $? -eq 0 ];then
        lava-test-case canconfig_can0 --result pass
else
        lava-test-case canconfig_can0 --result fail
fi
sleep 3

#bring up the devices
canconfig can0 start
if [ $? -eq 0 ];then
        lava-test-case start_can0 --result pass
else
        lava-test-case start_can0 --result fail
fi
sleep 4

#send frames
cansequence -p can0 &
x=$?
sleep 5
if [ $x -eq 0 ];then
        lava-test-case send_frames_through_can0 --result pass
else
        lava-test-case send_frames_through_can0 --result fail
fi
sleep 3
file_can=$(mktemp)

#receive frames
candump can0 > $file_can &
sleep 4
if [ -s $file_can ];then
        lava-test-case receive_frames_through_can0 --result pass
else
        lava-test-case receive_frames_through_can0 --result fail
fi
rm $file_can

sleep 3
canconfig can0 stop
if [ $? -eq 0 ];then
        lava-test-case stop_can0 --result pass
else
        lava-test-case stop_can0 --result fail
fi

sleep 5

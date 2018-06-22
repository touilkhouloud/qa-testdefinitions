#!/bin/sh


if [ ! -e /sys/class/net/can1 ];then
	lava-test-case show_can_stats --result skip
	lava-test-case show_can0_stats --result skip
	lava-test-case show_can1_stats --result skip
    exit 0
fi

# show can interfaces stats
cat /proc/net/can/stats
if [ $? -eq 0 ];then
	lava-test-case show_can_stats --result pass
else
	lava-test-case show_can_stats --result fail
fi

sleep 5

ip -d -s link show can0
if [ $? -eq 0 ];then
	lava-test-case show_can0_stats --result pass
else
	lava-test-case show_can0_stats --result fail
fi

sleep 5

ip -d -s link show can1
if [ $? -eq 0 ];then
	lava-test-case show_can1_stats --result pass
else
	lava-test-case show_can1_stats --result fail
fi

sleep 7

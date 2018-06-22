#!/bin/sh

#This test is writen taking the DRA7xx-EVM board as an example
#Theorical values of bitrate is from 1Kbit/s to 1Mbit/s
#Real values to provide transmission are between 10797 bit/s and 1909090git bit/s
#Real values that doesn't provide transmission but belong to the domain are between 781 bit/s and 5209999 bit/s

if [ ! -e /sys/class/net/can1 ];then
	lava-test-case canconfig_can0_bitrate --result skip
	lava-test-case receive_frames_through_can1 --result skip
	lava-test-case receive_frames_through_can1 --result skip
	lava-test-case receive_frames_through_can1 --result skip
	lava-test-case canconfig_can0_bitrate --result skip
	lava-test-case receive_frames_through_can1 --result skip
	exit 0
fi

#This is the first part of the test, that tests if the bitrate inserted belongs to the domain and if
#this first bitrate afford frames transmission or not
canconfig can0 stop
if [ $? -eq 0 ];then
        lava-test-case stop_can0 --result pass
else
        lava-test-case stop_can0 --result fail
fi
sleep 2
canconfig can1 stop
if [ $? -eq 0 ];then
        lava-test-case stop_can1 --result pass
else
        lava-test-case stop_can1 --result fail
fi
sleep 2

# b refers to bitrate

found_bitrate=0
for b in `seq 778 790`;do
	canconfig can0 bitrate $b
	x=$?
	if [ $x -eq 0 ];then
		lava-test-case can0_bitrate --result pass --measurement $b --units bit/s
		echo "$b is the first bitrate in the domain"
		found_bitrate=1
		canconfig can1 bitrate $b
		if [ $? -eq 0 ];then
			lava-test-case can1_bitrate --result pass --measurement $b --units bit/s
		else
			lava-test-case can1_bitrate --result fail --measurement $b --units bit/s
		fi
		sleep 2
		canconfig can0 start
		if [ $? -eq 0 ];then
			lava-test-case start_can0 --result pass
		else
			lava-test-case start_can0 --result fail
		fi
		sleep 2
		canconfig can1 start
		if [ $? -eq 0 ];then
			lava-test-case start_can1 --result pass
		else
			lava-test-case start_can1 --result fail
		fi
		sleep 2
		file_can=$(mktemp)
		cansequence -p can0 &
		candump can1 > $file_can &
		sleep 3
		if [ -s $file_can ];then
			lava-test-case Receive_can1 --result pass --measurement $b --units bit/s
		else
			lava-test-case Receive_can1 --result fail --measurement $b --units bit/s
			sleep 2
			echo "This bitrate $b belongs to the domain but doesn't provide frames transmission"
			break
		fi
		rm $file_can
	fi
done

if [ $found_bitrate -eq 0 ];then
	lava-test-case can0_bitrate --result fail --measurement $b --units bit/s
	sleep 2
	echo "There is no supportable bitrate in this interval"
fi
canconfig can0 stop
canconfig can1 stop
sleep 2
#This is the second part of the test, it tests the first bitrate to provide frames transmission

canconfig can0 stop
canconfig can1 stop
found_bitrate_for_transmisson=0
for b in `seq 10790 10800`;do
        canconfig can0 bitrate $b
        canconfig can1 bitrate $b
        canconfig can0 start
        canconfig can1 start
        sleep 3
        file_can=$(mktemp)
	cansequence -p can0 &
	candump can1 > $file_can &
	sleep 4
        if [ -s $file_can ];then
		found_bitrate_for_transmisson=1
		lava-test-case Receive_can1 --result pass --measurement $b --units bit/s
        	sleep 2
		echo "$b is the first supportable bitrate to provide transmission"
		break
	fi
	canconfig can0 stop
	canconfig can1 stop
	rm $file_can
done

if [ $found_bitrate_for_transmisson -eq 0 ];then
	lava-test-case Receive_can1 --result fail --measurement $b --units bit/s
	sleep 2
	echo "There is no bitrate in this interval to provide frames transmission"
fi


#This is the third part of the test, it tests the last bitrate to provide frames transmission

canconfig can0 stop
canconfig can1 stop
bitrate_no_transmission=0
for b in `seq 1909088 1909092`;do
        canconfig can0 bitrate $b
        canconfig can1 bitrate $b
        canconfig can0 start
        canconfig can1 start
        sleep 2
        file_can=$(mktemp)
        cansequence -p can0 &
        candump can1 > $file_can &
        sleep 3
	size=$(stat -c %s $file_can)
	if [ $size -eq 0 ];then
		bitrate_no_transmission=1
		B=($b-1)
		lava-test-case Receive_can1 --result pass --measurement $B --units bit/s
		lava-test-case Receive_can1 --result fail --measurement $b --units bit/s
		sleep 2
		echo "This bitrate $b doesn't provide frames transmission"
		echo "The last bitrate to provide frames transmission is $(($b-1))"
		break
	fi
	canconfig can0 stop
	canconfig can1 stop
        rm $file_can
done

if [ $bitrate_no_transmission -eq 0 ];then
	lava-test-case Receive_can1 --result pass --measurement $b --units bit/s
	echo "All bitrates in this interval provide frames transmission"
	canconfig can0 stop
	canconfig can1 stop
fi

#This is the last part of the test, it tests the last bitrate that belongs to the domain
sleep 3
canconfig can0 stop
canconfig can1 stop
out_of_domain=0
for b in `seq 5290999 5291000`;do
	canconfig can0 bitrate $b
	x=$?
	sleep 2
	if [ $x -ne 0 ];then
		out_of_domain=1
		lava-test-case can0_bitrate --result fail --measurement $b --units bit/s
		echo "$b is the first bitrate to be out of the domain"
		echo "The last bitrate to belong to the domain is $(($b-1))"
		break
	fi
done

if [ $out_of_domain -eq 0 ];then
	lava-test-case can0_bitrate --result pass --measurement $b --units bit/s
	echo "All bitrates in this interval belong to the domain"
	canconfig can0 stop
	canconfig can1 stop
fi

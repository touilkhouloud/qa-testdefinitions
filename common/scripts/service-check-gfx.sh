#!/bin/bash

REQUIREDSOCKETS="cynara.socket dbus.socket security-manager.socket"
REQUIREDSERVICES="afm-system-daemon.service afm-user-daemon.service connman.service ofono.service weston.service HomeScreen.service lightmediascanner.service bluetooth.service"

ALL="${REQUIREDSOCKETS} ${REQUIREDSERVICES}"
RESULT="unknown"

for i in ${ALL} ; do
    echo -e "\n########## Test for service ${i} being active ##########\n"
    systemctl is-active ${i} >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
        RESULT="pass"
    else
        RESULT="fail"
    fi
    lava-test-case ${i} --result ${RESULT}

    if [ x"fail" == x"${RESULT}" ] ; then
        systemctl status ${i} || true
    fi
    echo -e "\n########## Result for service ${i} : $RESULT ##########\n"
done

exit 0
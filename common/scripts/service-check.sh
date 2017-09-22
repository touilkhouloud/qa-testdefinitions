#!/bin/bash

REQUIREDSOCKETS="cynara.socket dbus.socket security-manager.socket"
REQUIREDSERVICES="afm-system-daemon.service afm-user-daemon.service connman.service ofono.service weston.service HomeScreen.service lightmediascanner.service bluetooth.service"

ALL="${REQUIREDSOCKETS} ${REQUIREDSERVICES}"
RESULT="unknown"

for i in ${ALL} ; do
    systemctl is-active ${i} >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
        RESULT="pass"
    else
        RESULT="fail"
    fi
    lava-test-case ${i} --result ${RESULT}
done

exit 0
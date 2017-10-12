#!/bin/bash

REQUIREDSOCKETS="cynara.socket security-manager.socket"
REQUIREDSERVICES="afm-system-daemon.service afm-user-daemon.service connman.service"

ALL="${REQUIREDSOCKETS} ${REQUIREDSERVICES}"
RESULT="unknown"

# add delay for services to fully start
sleep 5

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
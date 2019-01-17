#!/bin/bash

export LANG=C
export TERM=dumb


TAGS="$*"
REQUIREDSOCKETS="cynara.socket dbus.socket security-manager.socket"
REQUIREDSERVICES1="afm-system-daemon.service connman.service ofono.service weston.service bluetooth.service"
REQUIREDSERVICES2=""

for t in $TAGS; do
	for s in $REQUIREDSERVICES1; do
		if [ "$t.service" == "$s" ]; then
			REQUIREDSERVICES2="$REQUIREDSERVICES2 $s"
		fi
	done
done

echo "$REQUIREDSERVICES2"

ALL="${REQUIREDSOCKETS} ${REQUIREDSERVICES2}"
RESULT="unknown"

# add delay for services to fully start
sleep 10

for i in ${ALL} ; do
    echo -e "\n\n########## Test for service ${i} being active ##########\n\n"

    systemctl is-active ${i} >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
        RESULT="pass"
    else
        RESULT="fail"
    fi

    # lava-test-case ${i} --result ${RESULT}
    # systemctl status ${i} || true
    # echo -e "\n\n"

    echo -e "\n\n########## Result for service ${i} : $RESULT ##########\n\n"
done

echo "------------------------------------------------"
echo "All systemd units:"
echo "------------------------------------------------"
systemctl list-units || true
echo "------------------------------------------------"
echo "Only the failed systemd units:"
echo "------------------------------------------------"
( systemctl list-units | grep failed ) || true

exit 0
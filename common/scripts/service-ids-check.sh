#!/bin/bash
#-----------------------------------------------------
# This scripts allows to check the ids (user and/or group)
# of running services.
# It doesn't check that the service runs because this is
# the object of other tests.
# If a process doesn't run it emits an unknown status for
# the service, but not a fail.
# When there are multiple instance of a service, it checks
# that at least one instance matches expectation.
# Author: jose.bollo@iot.bzh
#-----------------------------------------------------

# out of LAVA run
if ! type lava-test-case 2>/dev/null; then
	lava-test-case() { echo "lava-test-case $*"; }
fi
if ! type lava-test-set 2>/dev/null; then
	lava-test-set() { echo "lava-test-set $*"; }
fi

# extraction of numeric ids for user and group
get-id() {
	local id="$1" file="$2"
	if grep -q "^${id}:" "$file"; then
		grep "^${id}:" "$file" | cut -d: -f3
	else
		echo -n "$id"
	fi
}
get-uid() { get-id "$1" /etc/passwd; }
get-gid() { get-id "$1" /etc/group; }

# extraction of numeric effective ids of processes
get-p-id() {
	local pid="$1" field="$2"
	grep "$field" "/proc/$pid/status" | cut -f3
}
get-p-uid() { get-p-id "$1" "Uid:"; }
get-p-gid() { get-p-id "$1" "Gid:"; }

# check the process status
check-p-ids() {
	local pid="$1" uid="$2" gid="$3"
	local u=$(get-p-uid "$pid")
	local g=$(get-p-gid "$pid")
	[[ -z "$uid" || "$uid" -eq "$u" ]] && [[ -z "$gid" || "$gid" -eq "$g" ]]
}
check-user-group() {
	local service="$1" user="$2" group="$3"
	local name="${service}-${user}-${group}"
	local pid uid=$(get-uid "$user") gid=$(get-gid "$group")

	if ! pgrep -c "^$service\$" > /dev/null 2>&1; then
		lava-test-case "$name" --result unknown
		return 0
	fi

	for pid in $(pgrep "^$service\$"); do
		if check-p-ids "$pid" "$uid" "$gid"; then
			lava-test-case "$name" --result pass
			return 0
		fi
	done
	lava-test-case "$name" --result fail
	return 1
}
check-user() { check-user-group "$1" "$2" ""; }
check-group() { check-user-group "$1" "" "$2"; }

# the test effective
lava-test-set start check-services-user-group

check-user-group	weston		display		display

lava-test-set stop check-services-user-group

exit 0

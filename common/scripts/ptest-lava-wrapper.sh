#!/bin/bash

REQUIREDPTESTS="busybox"

# Check if ptest packages are installed
command -v ptest-runner >/dev/null 2>&1
if [ $? -ne 0 ] ; then
    lava-test-case ptest-installed --result FAIL
else
    # Run ptests for specified packages
    for unit in ${REQUIREDPTESTS}; do
        UNIT_LOG=$(ptest-runner ${unit} 2> /dev/null)
        if [ $? -eq 0 ] ; then
            lava-test-set start ptest-$unit
            # grep: Get only the ptests results, no log
            # sed 1: replace spaces by hyphens
            # sed 2: remove any special character
            # sed 3: find status and test name, wrap it in a lava-test-case call
            # sh: execute the lava-test-case commands
            echo "$UNIT_LOG" | grep -e 'PASS' -e 'FAIL' | sed 's/ /-/g' | sed 's/[^a-z|A-Z|0-9|-]//g' | sed 's/\([^-]*\)-\(.*\)/lava-test-case \2 --result \1/' | sh
            lava-test-set stop ptest-$unit
        else
            lava-test-case ptest-runner ${unit} --result fail
        fi
    done
    lava-test-case ptest-runtime --measurement $SECONDS --units seconds --result PASS
fi

# Wait for LAVA to parse all the tests from stdout
sleep 60
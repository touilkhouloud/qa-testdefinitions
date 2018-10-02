#!/bin/bash

# Check if ptest packages are installed
command -v ptest-runner >/dev/null 2>&1
if [ $? -ne 0 ] ; then
    lava-test-case ptest-installed --result SKIP
else
    # Run ptests for specified packages
        lava-test-set start ptest-full

        UNIT_LOG=$(ptest-runner 2> results.log )
        if [ $? -eq 0 ] ; then
            # grep: Get only the ptests results, no log
            # sed 1: replace spaces by hyphens
            # sed 2: remove any special character
            # sed 3: find status and test name, wrap it in a lava-test-case call
            # sh: execute the lava-test-case commands
            test_pass=$(echo "$UNIT_LOG" | grep -e 'PASS' | wc -l)
            test_fail=$(echo "$UNIT_LOG" | grep -e 'FAIL' | wc -l)
            lava-test-case passed-commands --result PASS --measurement $test_pass --units pass
            if ! [ x"0" = x"$test_fail"] ; then
              lava-test-case failed-commands --result FAIL --measurement $test_fail --units fail
              echo "$UNIT_LOG" | grep -e 'FAIL'
            fi
        else
            lava-test-case ptest-runner ptest-full --result fail
        fi

        lava-test-set stop ptest-full

    lava-test-case ptest-runtime --measurement $SECONDS --units seconds --result PASS
fi

# Wait for LAVA to parse all the tests from stdout
sleep 15

cat results.log

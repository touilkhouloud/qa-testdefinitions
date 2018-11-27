#!/bin/bash

# Check if ptest packages are installed
command -v ptest-runner >/dev/null 2>&1
if [ $? -ne 0 ] ; then
    lava-test-case ptest-installed --result SKIP
else
    lava-test-case ptest-installed --result PASS
    ptest-runner -L
    lava-test-case ptest-runtime --measurement $SECONDS --units seconds --result PASS
fi

# Wait for LAVA to parse all the tests from stdout
sleep 15

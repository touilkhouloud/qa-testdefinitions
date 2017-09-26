#!/bin/bash

result=unkown
ANIMALS=42
PENGUINS=0

get_result () {
    if [ $? -eq "0" ]; then
        echo "pass"
    else
        echo "fail"
    fi
}

get_animals_count() {
    echo $ANIMALS
}

get_penguins_count() {
    echo $PENGUINS
}

echo "My test skeleton"

set -x

# Reporting commands results as they get executed
lava-test-set start print-to-log
echo "Hello"
result=$(get_result)
lava-test-case echo-hello --result $result
echo "Bye !"
result=$(get_result)
lava-test-case echo-bye --result $result
ls
result=$(get_result)
lava-test-case ls --result $result
lava-test-set stop print-to-log

set +x

# Reporting constant tests
lava-test-set start constant
lava-test-case always-pass --result pass
lava-test-case always-fail --result fail
lava-test-set stop constant

# Animals custom testing
animals_count=$(get_animals_count)
if [ $animals_count -ne 0 ]; then
    result_animals=pass
else
    result_animals=fail
fi
penguins_count=$(get_penguins_count)
if [ $penguins_count -ne 0 ]; then
    result_penguins=pass
else
    result_penguins=fail
fi

# Reporting of animals tests
lava-test-set start animals-measure
lava-test-case any-animals --result $result_animals --measurement $animals_count --units animals
lava-test-case any-penguins --result $result_penguins --measurement $penguins_count --units penguins
lava-test-set stop animals-measure

exit 0

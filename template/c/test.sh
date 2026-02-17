#!/bin/bash

function run_test_eq() {
    local name=$1
    local class=$2
    local command=$3
    local expected=$4

    echo -ne "Running $name ...\n"
    eval $command >/dev/null 2>&1
    local status=$?

    if [ $status -eq $expected ]; then
        echo -e "SUCCESS\n"
        echo "    <testcase name='$name' classname='$class'/>" >> test-results.xml
        return 0
    else
        echo -e "FAILURE\n  Got: $status\n  Expected: $expected\n"
        echo "    <testcase name='$name' classname='$class'><failure message='Expected $expected'>Got $status</failure></testcase>" >> test-results.xml
        return 1
    fi
}

function run_test_check_print() {
    local name=$1
    local class=$2
    local command=$3
    local expected=$4

    echo -e "Running $name ..."
    output=$(eval $command)
    status=$?

    if [ $status -eq 0 ] && [ "$output" == "$expected" ]; then
        echo -e "SUCCESS\n"
        echo "    <testcase name='$name' classname='$class'/>" >> test-results.xml
        return 0
    else
        echo -e "FAILURE\n  Got: '$output' (Exit code: $status)\n  Expected: '$expected'\n"
        echo "    <testcase name='$name' classname='$class'><failure message='Expected \"$expected\" with exit code 0'>Got \"$output\" with exit code $status</failure></testcase>" >> test-results.xml
        return 1
    fi
}


function test_jenkins () {
    local passed=0
    local total=0

    echo '<?xml version="1.0" encoding="UTF-8"?><testsuites><testsuite name="WhanosTests">' > test-results.xml

    printf "\n+--------------------------------------------------+\n"
    printf "|                MY JENKINS TESTS                  |\n"
    printf "+--------------------------------------------------+\n\n"

    echo -e "--- [ BASICS ] ---\n"
    
    run_test_eq "Test_Exit_84_On_Args" "Basics" "./hello fuck" 84 && ((passed++))
    ((total++))

    run_test_eq "Test_Exit_84_On_Args" "Basics" "./hello fuck" 84 && ((passed++))
    ((total++))
    
    run_test_check_print "Test_Output_Will" "Basics" "./hello" "Hello, will!" && ((passed++))
    ((total++))

    run_test_check_print "Test_Output_Anon" "Basics" "./hello" "Hello, anonymous!" && ((passed++))
    ((total++))

    run_test_eq "Test_Exit_84_On_Args" "Basics" "./hello fuck" 84 && ((passed++))
    ((total++))

    echo '</testsuite></testsuites>' >> test-results.xml

    local percent=$(( (passed * 100) / total ))
    [ $percent -lt 100 ]
    [ $percent -lt 50 ]

    printf "\n+------------------------------------------------------+\n"
    printf "|                                                      | \n"
    printf "|          FINAL RESULT: %2d /%2d passed (%3d%%)          |\n" "$passed" "$total" "$percent"
    printf "|                                                      | \n"
    printf "+------------------------------------------------------+\n\n"
    
    exit 0
}

test_jenkins
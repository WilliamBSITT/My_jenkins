#!/bin/bash

# --- CONFIGURATION ---
PORT=8081
URL="http://127.0.0.1:$PORT"

python app.py > server.log 2>&1 &
APP_PID=$!

for i in {1..5}; do
    curl -s $URL/ > /dev/null && break
    sleep 1
done

function run_test_http_code() {
    local name=$1
    local class=$2
    local endpoint=$3
    local expected_code=$4

    echo -n "Running $name (Code $expected_code) ... "
    local status_code=$(curl -o /dev/null -s -w "%{http_code}" "$URL$endpoint")

    if [ "$status_code" -eq "$expected_code" ]; then
        echo "SUCCESS"
        echo "    <testcase name='$name' classname='$class'/>" >> test-results.xml
        return 0
    else
        echo "FAILURE (Got $status_code)"
        echo "    <testcase name='$name' classname='$class'><failure message='Expected $expected_code'>Got $status_code</failure></testcase>" >> test-results.xml
        return 1
    fi
}

function run_test_content() {
    local name=$1
    local class=$2
    local endpoint=$3
    local expected_text=$4

    echo -n "Running $name (Content) ... "
    local output=$(curl -s "$URL$endpoint")
    
    if [[ "$output" == *"$expected_text"* ]]; then
        echo "SUCCESS"
        echo "    <testcase name='$name' classname='$class'/>" >> test-results.xml
        return 0
    else
        echo "FAILURE"
        echo "    <testcase name='$name' classname='$class'><failure message='Expected $expected_text'>Got $output</failure></testcase>" >> test-results.xml
        return 1
    fi
}

function test_jenkins () {
    local passed=0
    local total=0

    echo '<?xml version="1.0" encoding="UTF-8"?><testsuites><testsuite name="FlaskApiTests">' > test-results.xml

    printf "\n+--------------------------------------------------+\n"
    printf "|             FLASK API UNIT TESTS                 |\n"
    printf "+--------------------------------------------------+\n\n"

    # --- TEST CASES ---
    run_test_http_code "Test_Home_Status" "Endpoints" "/" 200 && ((passed++))
    ((total++))

    run_test_content "Test_Home_Content" "Content" "/" "Hello World!" && ((passed++))
    ((total++))

    run_test_content "Test_Greet_Alice" "Dynamic" "/greet/Alice" "Hello, Alice!" && ((passed++))
    ((total++))

    run_test_http_code "Test_Admin_Forbidden" "Security" "/admin" 403 && ((passed++))
    ((total++))

    echo '  </testsuite></testsuites>' >> test-results.xml

    local percent=$(( (passed * 100) / total ))

    printf "\n+------------------------------------------------------+\n"
    printf "|          FINAL RESULT: %2d /%2d passed (%3d%%)          |\n" "$passed" "$total" "$percent"
    printf "+------------------------------------------------------+\n\n"
    
    exit 0
}

test_jenkins
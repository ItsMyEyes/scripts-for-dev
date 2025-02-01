#!/bin/bash

set -euo pipefail

# Constants
readonly EXCLUDED_DIRS=(
    "/cmd/"
    "/vendor/"
    "mock"
    "/scripts/"
    "/internal/app"
    "/db"
    "/api/"
    "/pkg"
    "/docs"
)

# Function to get list of Go packages excluding specified directories
get_package_list() {
    local exclude_pattern=""
    for dir in "${EXCLUDED_DIRS[@]}"; do
        exclude_pattern="${exclude_pattern:+${exclude_pattern}|}${dir}"
    done
    go list ./... | grep -vE "$exclude_pattern"
}

# Function to run tests and capture output
run_tests() {
    local packages="$1"
    echo "=== RUNNING TEST ==="
    go test -cover $packages | tee test.out
}

# Function to parse a single test result line
parse_test_line() {
    local line="$1"
    if [[ $line =~ ok ]]; then
        handle_success "$line"
    elif [[ $line =~ FAILED|FAIL: ]]; then
        handle_failure "$line"
    elif [[ $line =~ \? ]]; then
        handle_no_test "$line"
    fi
}

# Function to handle successful test case
handle_success() {
    local line="$1"
    ((success_count++))
    local coverage=$(echo "$line" | awk '{print $5}')
    local coverage_no_percent=${coverage//\%/}
    local coverage_value=$(echo "$coverage_no_percent" | awk -F. '{ print $1 }')
    ((coverage_sum+=coverage_value))
    ((list_count++))
}

# Function to handle failed test case
handle_failure() {
    local line="$1"
    local package=$(echo "$line" | awk '{print $2}')
    ((list_count++))
    echo "Failed test in package: $package"
}

# Function to handle no test case
handle_no_test() {
    local line="$1"
    local package=$(echo "$line" | awk '{print $2}')
    ((list_no_testcase++))
    echo "No test files in package: $package"
}

# Function to calculate and print test summary
print_summary() {
    local average_coverage=0
    local average_coverage_no_testcase=0
    
    if [ "$list_count" -gt 0 ]; then
        average_coverage=$((coverage_sum / list_count))
        average_coverage_no_testcase=$((coverage_sum / (list_count + list_no_testcase)))
    fi

    echo -e "\n=== TEST SUMMARY ==="
    echo "Success: $success_count/$list_count"
    echo "Average Success Coverage: $average_coverage%"
    echo "No Testcase: $list_no_testcase"
    echo "Average With No Testcase: $average_coverage_no_testcase%"
}

# Function to validate test results
validate_results() {
    if [ "$success_count" -ne "$list_count" ]; then
        echo "Test count mismatch: success_count=$success_count, list_count=$list_count"
        return 1
    fi
    return 0
}

# Main function
main() {
    # Initialize counters
    success_count=0
    coverage_sum=0
    list_count=0
    list_no_testcase=0

    local packages=$(get_package_list)
    run_tests "$packages"

    while IFS= read -r line; do
        parse_test_line "$line"
    done < test.out

    print_summary
    validate_results
}

# Execute main function
main "$@"
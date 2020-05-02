#!/bin/sh

# Tests of netaddr_calc.sh

. ./netaddr_calc.sh

### Test executor ############################################################

# Total number of executed tests
TESTS=0
# PASSed tests
TESTS_PASS=0
# FAILed tests
TESTS_FAIL=0

# test ID FUN STATUS OUT [ARG...]
# Run a single test of a function call.
# P: ID = id of the test, used in result report
#    FUN = called function name
#    STATUS = expected status code returned by FUN
#    OUT = expected stdout of FUN
#    ARG = arguments of FUN
# R: 0 = test passed, 1 = test failed
test()
{
    local id fun status out f_status f_out fail
    id="$1"
    fun="$2"
    status="$3"
    out="$4"
    shift 4
    TESTS=$((TESTS+1))
    echo "RUN  $id"
    f_out=`$fun "$@"`
    f_status=$?
    fail=""
    if [ $f_status != $status ]; then
        fail="$err status=$f_status"
    fi
    if [ "$f_out" != "$out" ]; then
        fail="$err out=$f_out"
    fi
    if [ -z "$fail" ]; then
        echo "PASS $id"
        TESTS_PASS=$((TESTS_PASS+1))
        return 0
    else
        echo "FAIL $id$fail"
        TESTS_FAIL=$((TESTS_FAIL+1))
        return 1
    fi
}

### Test suites ##############################################################

# Sets of tests, each is a function named test_* and its name (without test_)
# must be included in variable TEST_SUITES.

# Test the test environment
test_test()
{
    test true true 0 ''
    test false false 1 ''
    test echo echo 0 'hello world' hello world
}

# Test address+mask splitting
test_addrmask()
{
    test addr4 ip_addrmask2addr 0 192.168.2.59 192.168.2.59/24 
    test mask4 ip_addrmask2mask 0 24 192.168.2.59/24 
    test addr6 ip_addrmask2addr 0 2001:470:5a02:0:9441:4471:82d3:368c \
        2001:470:5a02:0:9441:4471:82d3:368c/64
    test mask6 ip_addrmask2mask 0 64 2001:470:5a02:0:9441:4471:82d3:368c/64
}

# List of test suites (separated by whitespace)
TEST_SUITES='addrmask test'

### Entry point ##############################################################

if [ "$#" = 0 ]; then
    set $TEST_SUITES
fi
for t in $*; do
    case " $TEST_SUITES " in
        *" $t "*)
            ;;
        *)
            echo "Unknown test suite \"$t\". Available test suites:"
            echo $TEST_SUITES
            return 1
            ;;
    esac
done
for t in $*; do
    echo ">>> BEGIN $t >>>"
    eval test_$t
    echo "<<< END $t <<<"
done

echo "=== TOTAL RESULTS ==="
echo "TESTS:  $TESTS"
echo "PASS:   $TESTS_PASS"
echo "FAIL:   $TESTS_FAIL"
if [ $TESTS_FAIL = 0 ]; then
    echo "RESULT: PASS"
    return 0
else
    echo "RESULT: FAIL"
    return 1
fi

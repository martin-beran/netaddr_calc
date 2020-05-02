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

# Test address+mask splitting
test_addrmask()
{
    test addr4 ip_addrmask2addr 0 192.168.2.59 192.168.2.59/24 
    test mask4 ip_addrmask2mask 0 24 192.168.2.59/24 
    test addr6 ip_addrmask2addr 0 2001:470:5a02:0:9441:4471:82d3:368c \
        2001:470:5a02:0:9441:4471:82d3:368c/64
    test mask6 ip_addrmask2mask 0 64 2001:470:5a02:0:9441:4471:82d3:368c/64
}

# Test operations with byte sequences
test_bytes()
{
    test bits2mask1_0 bytes_bits2mask 0 0 1 0
    test bits2mask1_1 bytes_bits2mask 0 128 1 1
    test bits2mask1_2 bytes_bits2mask 0 192 1 2
    test bits2mask1_3 bytes_bits2mask 0 224 1 3
    test bits2mask1_4 bytes_bits2mask 0 240 1 4
    test bits2mask1_5 bytes_bits2mask 0 248 1 5
    test bits2mask1_6 bytes_bits2mask 0 252 1 6
    test bits2mask1_7 bytes_bits2mask 0 254 1 7
    test bits2mask1_8 bytes_bits2mask 0 255 1 8

    test bitmask2mask4_0 bytes_bits2mask 0 0.0.0.0 4 0
    test bitmask2mask4_1 bytes_bits2mask 0 128.0.0.0 4 1
    test bitmask2mask4_8 bytes_bits2mask 0 255.0.0.0 4 8
    test bitmask2mask4_10 bytes_bits2mask 0 255.192.0.0 4 10
    test bitmask2mask4_16 bytes_bits2mask 0 255.255.0.0 4 16
    test bitmask2mask4_20 bytes_bits2mask 0 255.255.240.0 4 20
    test bitmask2mask4_24 bytes_bits2mask 0 255.255.255.0 4 24
    test bitmask2mask4_25 bytes_bits2mask 0 255.255.255.128 4 25
    test bitmask2mask4_30 bytes_bits2mask 0 255.255.255.252 4 30
    test bitmask2mask4_31 bytes_bits2mask 0 255.255.255.254 4 31
    test bitmask2mask4_32 bytes_bits2mask 0 255.255.255.255 4 32

    test bitmask2mask16_0 bytes_bits2mask 0 \
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 16 0
    test bitmask2mask16_64 bytes_bits2mask 0 \
        255.255.255.255.255.255.255.255.0.0.0.0.0.0.0.0 16 64

    test bytes_invert_1 bytes_invert 0 0 255
    test bytes_invert_2 bytes_invert 0 255 0
    test bytes_invert_3 bytes_invert 0 1 254
    test bytes_invert_4 bytes_invert 0 254 1
    test bytes_invert_5 bytes_invert 0 129 126
    test bytes_invert_6 bytes_invert 0 126 129
    test bytes_invert_7 bytes_invert 0 255.254.127.15.170.0 0.1.128.240.85.255
    test bytes_invert_8 bytes_invert 0 0.1.128.240.85.255 255.254.127.15.170.0

    test bytes_and_1 bytes_and 0 0 0 0
    test bytes_and_2 bytes_and 0 0 0 1
    test bytes_and_3 bytes_and 0 0 1 0
    test bytes_and_4 bytes_and 0 1 1 1
    test bytes_and_5 bytes_and 0 0.0.0.14 0.255.0.254 0.0.15.15

    test bytes_or_1 bytes_or 0 0 0 0
    test bytes_or_2 bytes_or 0 1 0 1
    test bytes_or_3 bytes_or 0 1 1 0
    test bytes_or_4 bytes_or 0 1 1 1
    test bytes_or_5 bytes_or 0 0.255.15.255 0.255.0.254 0.0.15.15

    test bytes_from_hex_0_1 bytes_from_hex 0 0 0
    test bytes_from_hex_0_2 bytes_from_hex 0 0 0x0
    test bytes_from_hex_0_3 bytes_from_hex 0 0 00
    test bytes_from_hex_0_4 bytes_from_hex 0 0 0x00
    test bytes_from_hex_0_5 bytes_from_hex 0 0 0-0
    test bytes_from_hex_0_6 bytes_from_hex 0 0 0:0
    test bytes_from_hex_x bytes_from_hex 0 3 3
    test bytes_from_hex_x_lo bytes_from_hex 0 26 1a
    test bytes_from_hex_x_hi bytes_from_hex 0 160 A0
    test bytes_from_hex_x_delim bytes_from_hex 0 160 a:0
    test bytes_from_hex_x_mix bytes_from_hex 0 254 fE
    test bytes_from_hex_multi bytes_from_hex 0 1.162.179.77 0x01a2b34d
    test bytes_from_hex_multi_delim1 bytes_from_hex 0 1.162.179.77 01:a2:b3:4d
    test bytes_from_hex_multi_delim2 bytes_from_hex 0 \
        1.162.59.196.93.110 01-A2-3B-c4-5D-6e
}

# Test operations with IPv4 addresses
test_ipv4()
{
    test bits2mask_0 ipv4_bits2mask 0 0.0.0.0 0
    test bits2mask_8 ipv4_bits2mask 0 255.0.0.0 8
    test bits2mask_12 ipv4_bits2mask 0 255.240.0.0 12
    test bits2mask_16 ipv4_bits2mask 0 255.255.0.0 16
    test bits2mask_24 ipv4_bits2mask 0 255.255.255.0 24

    test ipv4_invert_1 ipv4_invert 0 255.255.255.0 0.0.0.255
    test ipv4_invert_2 ipv4_invert 0 0.0.0.255 255.255.255.0
    test ipv4_invert_3 ipv4_invert 0 255.240.0.0 0.15.255.255
    test ipv4_invert_4 ipv4_invert 0 0.15.255.255 255.240.0.0

    test ipv4_and_1 ipv4_and 0 192.168.2.0 192.168.2.1 255.255.255.0
    test ipv4_and_2 ipv4_and 0 172.16.0.0 172.20.2.1 255.240.0.0
    test ipv4_or_1 ipv4_or 0 172.20.2.1 172.16.0.0 0.4.2.1
    test ipv4_or_2 ipv4_or 0 192.168.31.255 192.168.16.1 0.0.15.255

    test ipv4_combine_1 ipv4_combine 0 192.168.1.4 \
        192.168.1.1 255.255.255.0 10.1.2.4
    test ipv4_combine_2 ipv4_combine 0 10.232.3.100 \
        10.236.16.1 255.240.0.0 192.168.3.100
    test ipv4_combine_3 ipv4_combine 0 192.168.2.1 \
        192.168.30.1 255.255.0.255 10.1.2.3
}

# Test the test environment
test_test()
{
    test true true 0 ''
    test false false 1 ''
    test echo echo 0 'hello world' hello world
}

# Temporary tests
test_tmp()
{
    :
}

# List of test suites (separated by whitespace)
TEST_SUITES='addrmask bytes ipv4 test tmp'

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

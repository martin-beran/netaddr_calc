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

# run_test ID FUN STATUS OUT [ARG...]
# Run a single test of a function call.
# P: ID = id of the test, used in result report
#    FUN = called function name
#    STATUS = expected status code returned by FUN
#    OUT = expected stdout of FUN
#    ARG = arguments of FUN
# R: 0 = test passed, 1 = test failed
run_test()
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

# Test operations with byte sequences
test_bytes()
{
    run_test bytes_from_hex_0_1 bytes_from_hex 0 0 0
    run_test bytes_from_hex_0_2 bytes_from_hex 0 0 0x0
    run_test bytes_from_hex_0_3 bytes_from_hex 0 0 00
    run_test bytes_from_hex_0_4 bytes_from_hex 0 0 0x00
    run_test bytes_from_hex_0_5 bytes_from_hex 0 0 0-0
    run_test bytes_from_hex_0_6 bytes_from_hex 0 0 0:0
    run_test bytes_from_hex_x bytes_from_hex 0 3 3
    run_test bytes_from_hex_x_lo bytes_from_hex 0 26 1a
    run_test bytes_from_hex_x_hi bytes_from_hex 0 160 A0
    run_test bytes_from_hex_x_delim bytes_from_hex 0 160 a:0
    run_test bytes_from_hex_x_mix bytes_from_hex 0 254 fE
    run_test bytes_from_hex_multi bytes_from_hex 0 1.162.179.77 0x01a2b34d
    run_test bytes_from_hex_multi_delim1 bytes_from_hex 0 \
        1.162.179.77 01:a2:b3:4d
    run_test bytes_from_hex_multi_space bytes_from_hex 0 \
        1.162.179.77 '01 a2 b3 4d'
    run_test bytes_from_hex_multi_delims bytes_from_hex 0 \
        1.162.179.77 0:1:a:2:b:3:4:d
    run_test bytes_from_hex_multi_delims2 bytes_from_hex 0 \
        1.162.179.77 0.1:a.2:b.3:4.d
    run_test bytes_from_hex_multi_delim2 bytes_from_hex 0 \
        1.162.59.196.93.110 01-A2-3B-c4-5D-6e
    run_test bytes_from_hex_mac bytes_from_hex 0 \
        16.42.179.76.213.110 10:2a:b3:4c:d5:6e

    run_test bytes_to_hex bytes_to_hex 0 c0a8d201 192.168.210.1
    run_test bytes_to_hex_prefix bytes_to_hex 0 0xc0a8d201 192.168.210.1 0x
    run_test bytes_to_hex_lower bytes_to_hex 0 0xc0a8d201 192.168.210.1 0x ''
    run_test bytes_to_hex_upper bytes_to_hex 0 0XC0A8D201 192.168.210.1 0X U
    run_test bytes_to_hex_delim2 bytes_to_hex 0 \
        10:2a:b3:4c:d5:6e 16.42.179.76.213.110 '' l :
    run_test bytes_to_hex_delim21 bytes_to_hex 0 \
        1-0:2-a:b-3:4-c:d-5:6-e 16.42.179.76.213.110 '' l : -

    run_test bits2mask1_0 bytes_bits2mask 0 0 1 0
    run_test bits2mask1_1 bytes_bits2mask 0 128 1 1
    run_test bits2mask1_2 bytes_bits2mask 0 192 1 2
    run_test bits2mask1_3 bytes_bits2mask 0 224 1 3
    run_test bits2mask1_4 bytes_bits2mask 0 240 1 4
    run_test bits2mask1_5 bytes_bits2mask 0 248 1 5
    run_test bits2mask1_6 bytes_bits2mask 0 252 1 6
    run_test bits2mask1_7 bytes_bits2mask 0 254 1 7
    run_test bits2mask1_8 bytes_bits2mask 0 255 1 8

    run_test bitmask2mask4_0 bytes_bits2mask 0 0.0.0.0 4 0
    run_test bitmask2mask4_1 bytes_bits2mask 0 128.0.0.0 4 1
    run_test bitmask2mask4_8 bytes_bits2mask 0 255.0.0.0 4 8
    run_test bitmask2mask4_10 bytes_bits2mask 0 255.192.0.0 4 10
    run_test bitmask2mask4_16 bytes_bits2mask 0 255.255.0.0 4 16
    run_test bitmask2mask4_20 bytes_bits2mask 0 255.255.240.0 4 20
    run_test bitmask2mask4_24 bytes_bits2mask 0 255.255.255.0 4 24
    run_test bitmask2mask4_25 bytes_bits2mask 0 255.255.255.128 4 25
    run_test bitmask2mask4_30 bytes_bits2mask 0 255.255.255.252 4 30
    run_test bitmask2mask4_31 bytes_bits2mask 0 255.255.255.254 4 31
    run_test bitmask2mask4_32 bytes_bits2mask 0 255.255.255.255 4 32

    run_test bitmask2mask16_0 bytes_bits2mask 0 \
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 16 0
    run_test bitmask2mask16_64 bytes_bits2mask 0 \
        255.255.255.255.255.255.255.255.0.0.0.0.0.0.0.0 16 64

    run_test bytes_invert_1 bytes_invert 0 0 255
    run_test bytes_invert_2 bytes_invert 0 255 0
    run_test bytes_invert_3 bytes_invert 0 1 254
    run_test bytes_invert_4 bytes_invert 0 254 1
    run_test bytes_invert_5 bytes_invert 0 129 126
    run_test bytes_invert_6 bytes_invert 0 126 129
    run_test bytes_invert_7 bytes_invert 0 \
        255.254.127.15.170.0 0.1.128.240.85.255
    run_test bytes_invert_8 bytes_invert 0 \
        0.1.128.240.85.255 255.254.127.15.170.0

    run_test bytes_and_1 bytes_and 0 0 0 0
    run_test bytes_and_2 bytes_and 0 0 0 1
    run_test bytes_and_3 bytes_and 0 0 1 0
    run_test bytes_and_4 bytes_and 0 1 1 1
    run_test bytes_and_5 bytes_and 0 0.0.0.14 0.255.0.254 0.0.15.15

    run_test bytes_or_1 bytes_or 0 0 0 0
    run_test bytes_or_2 bytes_or 0 1 0 1
    run_test bytes_or_3 bytes_or 0 1 1 0
    run_test bytes_or_4 bytes_or 0 1 1 1
    run_test bytes_or_5 bytes_or 0 0.255.15.255 0.255.0.254 0.0.15.15
}

# Test address+mask splitting
test_ip()
{
    run_test addr4 ip_addrmask2addr 0 192.168.2.59 192.168.2.59/24
    run_test mask4 ip_addrmask2mask 0 24 192.168.2.59/24
    run_test addr6 ip_addrmask2addr 0 2001:470:5a02:0:9441:4471:82d3:368c \
        2001:470:5a02:0:9441:4471:82d3:368c/64
    run_test mask6 ip_addrmask2mask 0 64 2001:470:5a02:0:9441:4471:82d3:368c/64
}

# Test operations with IPv4 addresses
test_ipv4()
{
    run_test ipv4_from_bytes ipv4_from_bytes 0 192.168.1.2 192.168.1.2

    run_test ipv4_to_bytes ipv4_to_bytes 0 192.168.1.2 192.168.1.2

    run_test ipv4_bits2mask_0 ipv4_bits2mask 0 0.0.0.0 0
    run_test ipv4_bits2mask_8 ipv4_bits2mask 0 255.0.0.0 8
    run_test ipv4_bits2mask_12 ipv4_bits2mask 0 255.240.0.0 12
    run_test ipv4_bits2mask_16 ipv4_bits2mask 0 255.255.0.0 16
    run_test ipv4_bits2mask_24 ipv4_bits2mask 0 255.255.255.0 24
    run_test ipv4_bits2mask_32 ipv4_bits2mask 0 255.255.255.255 32

    run_test ipv4_invert_1 ipv4_invert 0 255.255.255.0 0.0.0.255
    run_test ipv4_invert_2 ipv4_invert 0 0.0.0.255 255.255.255.0
    run_test ipv4_invert_3 ipv4_invert 0 255.240.0.0 0.15.255.255
    run_test ipv4_invert_4 ipv4_invert 0 0.15.255.255 255.240.0.0

    run_test ipv4_and_1 ipv4_and 0 192.168.2.0 192.168.2.1 255.255.255.0
    run_test ipv4_and_2 ipv4_and 0 172.16.0.0 172.20.2.1 255.240.0.0

    run_test ipv4_or_1 ipv4_or 0 172.20.2.1 172.16.0.0 0.4.2.1
    run_test ipv4_or_2 ipv4_or 0 192.168.31.255 192.168.16.1 0.0.15.255

    run_test ipv4_combine_1 ipv4_combine 0 192.168.1.4 \
        192.168.1.1 10.1.2.4 255.255.255.0
    run_test ipv4_combine_2 ipv4_combine 0 10.232.3.100 \
        10.236.16.1 192.168.3.100 255.240.0.0
    run_test ipv4_combine_3 ipv4_combine 0 192.168.2.1 \
        192.168.30.1 10.1.2.3 255.255.0.255
    run_test ipv4_combine_mask_0 ipv4_combine 0 10.1.2.3 \
        192.168.30.1 10.1.2.3 0.0.0.0
    run_test ipv4_combine_mask_32 ipv4_combine 0 192.168.30.1 \
        192.168.30.1 10.1.2.3 255.255.255.255
    run_test ipv4_combine_no_mask ipv4_combine 0 192.168.2.40 \
        192.168.2.1 10.20.30.40
    run_test ipv4_combine_empty_mask ipv4_combine 0 192.168.2.40 \
        192.168.2.1 10.20.30.40 ''
    run_test ipv4_combine_hex_mask ipv4_combine 0 192.168.30.40 \
        192.168.2.1 10.20.30.40 0xffff0000
    run_test ipv4_combine_hex_prefix ipv4_combine 0 192.168.14.40 \
        192.168.2.1 10.20.30.40 20
}

# Test operations with IPv6 addresses
test_ipv6()
{
    run_test ipv6_lladdr2addr_global ipv6_lladdr2addr 0 \
        2001:470:6f:ca1:ed38:eb0f:69f:bd56 2001:470:6f:ca1:ed38:eb0f:69f:bd56
    run_test ipv6_lladdr2addr_llocal ipv6_lladdr2addr 0 \
        fe80::2e69:a4b4:5839:1ff8 fe80::2e69:a4b4:5839:1ff8%wlo1

    run_test ipv6_lladdr2scope_global ipv6_lladdr2scope 0 \
        '' 2001:470:6f:ca1:ed38:eb0f:69f:bd56
    run_test ipv6_lladdr2scope_llocal ipv6_lladdr2scope 0 \
        wlo1 fe80::2e69:a4b4:5839:1ff8%wlo1

    run_test ipv6_to_bytes_0 ipv6_to_bytes 0 \
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 ::
    run_test ipv6_to_bytes_full ipv6_to_bytes 0 \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.15 \
        2001:470:5a02:0:7308:c5e:6e:f
    run_test ipv6_to_bytes_short_begin_1 ipv6_to_bytes 0 \
        0.0.4.112.90.2.0.0.115.8.12.94.0.110.0.15 \
        ::470:5a02:0:7308:c5e:6e:f
    run_test ipv6_to_bytes_short_begin_2 ipv6_to_bytes 0 \
        0.0.0.0.90.2.0.0.115.8.12.94.0.110.0.15 \
        ::5a02:0:7308:c5e:6e:f
    run_test ipv6_to_bytes_short_end_1 ipv6_to_bytes 0 \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.0 \
        2001:470:5a02:0:7308:c5e:6e::
    run_test ipv6_to_bytes_short_end_2 ipv6_to_bytes 0 \
        32.1.4.112.90.2.0.0.115.8.12.94.0.0.0.0 \
        2001:470:5a02:0:7308:c5e::
    run_test ipv6_to_bytes_short_mid_1 ipv6_to_bytes 0 \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.15 \
        2001:470:5a02::7308:c5e:6e:f
    run_test ipv6_to_bytes_short_mid_2 ipv6_to_bytes 0 \
        32.1.4.112.90.2.0.0.0.0.12.94.0.110.0.15 \
        2001:470:5a02::c5e:6e:f
    run_test ipv6_to_bytes_short_mid_6 ipv6_to_bytes 0 \
        32.1.0.0.0.0.0.0.0.0.0.0.0.0.0.15 2001::f
    run_test ipv6_to_bytes_llocal ipv6_to_bytes 0 \
        254.128.0.0.0.0.0.0.185.2.212.180.169.203.117.198 \
        fe80::b902:d4b4:a9cb:75c6%eno2

    run_test ipv6_from_bytes_0 ipv6_from_bytes 0 \
        :: 0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0
    run_test ipv6_from_bytes_full ipv6_from_bytes 0 \
        2001:470:5a02:0:7308:c5e:6e:f \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.15
    run_test ipv6_from_bytes_short_begin_1 ipv6_from_bytes 0 \
        0:470:5a02:0:7308:c5e:6e:f \
        0.0.4.112.90.2.0.0.115.8.12.94.0.110.0.15
    run_test ipv6_from_bytes_short_begin_2 ipv6_from_bytes 0 \
        ::5a02:0:7308:c5e:6e:f \
        0.0.0.0.90.2.0.0.115.8.12.94.0.110.0.15
    run_test ipv6_from_bytes_short_end_1 ipv6_from_bytes 0 \
        2001:470:5a02:0:7308:c5e:6e:0 \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.0
    run_test ipv6_from_bytes_short_end_1a ipv6_from_bytes 0 \
        2001:470:5a02:a:7308:c5e:6e:0 \
        32.1.4.112.90.2.0.10.115.8.12.94.0.110.0.0
    run_test ipv6_from_bytes_short_end_2 ipv6_from_bytes 0 \
        2001:470:5a02:0:7308:c5e:: \
        32.1.4.112.90.2.0.0.115.8.12.94.0.0.0.0
    run_test ipv6_from_bytes_short_mid_1 ipv6_from_bytes 0 \
        2001:470:5a02:0:7308:c5e:6e:f \
        32.1.4.112.90.2.0.0.115.8.12.94.0.110.0.15
    run_test ipv6_from_bytes_short_mid_2 ipv6_from_bytes 0 \
        2001:470:5a02::c5e:6e:f \
        32.1.4.112.90.2.0.0.0.0.12.94.0.110.0.15
    run_test ipv6_from_bytes_short_mid_6 ipv6_from_bytes 0 \
        2001::f 32.1.0.0.0.0.0.0.0.0.0.0.0.0.0.15
    run_test ipv6_from_bytes_format_none ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0
    run_test ipv6_from_bytes_format_empty ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 ''
    run_test ipv6_from_bytes_format_canonical ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 canonical
    run_test ipv6_from_bytes_format_c_up ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 C
    run_test ipv6_from_bytes_format_c_lo ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 c
    run_test ipv6_from_bytes_format_short ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 short
    run_test ipv6_from_bytes_format_s_up ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 S
    run_test ipv6_from_bytes_format_s_lo ipv6_from_bytes 0 \
        2001::abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 s
    run_test ipv6_from_bytes_format_long ipv6_from_bytes 0 \
        2001:0:0:abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 long
    run_test ipv6_from_bytes_format_l_up ipv6_from_bytes 0 \
        2001:0:0:abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 L
    run_test ipv6_from_bytes_format_l_lo ipv6_from_bytes 0 \
        2001:0:0:abcd:123:45:6:0 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 l
    run_test ipv6_from_bytes_format_full ipv6_from_bytes 0 \
        2001:0000:0000:abcd:0123:0045:0006:0000 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 full
    run_test ipv6_from_bytes_format_f_up ipv6_from_bytes 0 \
        2001:0000:0000:abcd:0123:0045:0006:0000 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 F
    run_test ipv6_from_bytes_format_f_lo ipv6_from_bytes 0 \
        2001:0000:0000:abcd:0123:0045:0006:0000 \
        32.1.0.0.0.0.171.205.1.35.0.69.0.6.0.0 f

    run_test ipv6_bits2mask_0 ipv6_bits2mask 0 \
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 0
    run_test ipv6_bits2mask_8 ipv6_bits2mask 0 \
        255.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 8
    run_test ipv6_bits2mask_20 ipv6_bits2mask 0 \
        255.255.240.0.0.0.0.0.0.0.0.0.0.0.0.0 20
    run_test ipv6_bits2mask_48 ipv6_bits2mask 0 \
        255.255.255.255.255.255.0.0.0.0.0.0.0.0.0.0 48
    run_test ipv6_bits2mask_64 ipv6_bits2mask 0 \
        255.255.255.255.255.255.255.255.0.0.0.0.0.0.0.0 64
    run_test ipv6_bits2mask_128 ipv6_bits2mask 0 \
        255.255.255.255.255.255.255.255.255.255.255.255.255.255.255.255 128

    run_test ipv6_invert_1 ipv6_invert 0 \
        255.255.255.255.255.255.255.255.255.255.255.255.255.255.255.255 ::
    run_test ipv6_invert_2 ipv6_invert 0 \
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    run_test ipv6_invert_3 ipv6_invert 0 \
        255.255.255.255.255.255.255.255.0.0.0.0.0.0.0.0 ::ffff:ffff:ffff:ffff
    run_test ipv6_invert_4 ipv6_invert 0 \
        0.225.0.226.0.227.255.0.255.1.255.2.255.3.255.4 \
        ff1e:ff1d:ff1c:ff::fe:fd:fc:fb

    run_test ipv6_and_1 ipv6_and 0 0.0.0.0.0.0.0.0.0.0.0.0.18.0.86.120 \
        fe80::ff00:ffff ::1234:5678

    run_test ipv6_or_1 ipv6_or 0 254.128.0.0.0.0.0.0.0.0.0.0.255.52.255.255 \
        fe80::ff00:ffff ::1234:5678

    run_test ipv6_combine_1 ipv6_combine 0 \
        2001:470:6f:ca1:b902:d4b4:a9cb:75c6 \
        2001:470:6f:ca1::1 fe80::b902:d4b4:a9cb:75c6

    run_test ipv6_combine_1 ipv6_combine 0 \
        2001:470:6f:0:b902:d4b4:a9cb:75c6 \
        2001:470:6f:ca1::1 fe80::b902:d4b4:a9cb:75c6 48

    run_test ipv6_combine_1 ipv6_combine 0 \
        2001:470:6f:0:b902:d4b4:a9cb:75c6 \
        2001:470:6f:ca1::1 fe80::b902:d4b4:a9cb:75c6 ffff:ffff:ffff::

    run_test ipv6_eui64_1 ipv6_eui64 0 \
        fe80::7285:c2ff:fe78:8752 70:85:c2:78:87:52

    run_test ipv6_eui64_to_mac_1 ipv6_eui64_to_mac 0 \
        70:85:c2:78:87:52 fe80::7285:c2ff:fe78:8752
}

# Test operations with MAC addresses
test_mac()
{
    run_test mac_from_bytes mac_from_bytes 0 \
        10:2a:b3:4c:d5:6e 16.42.179.76.213.110

    run_test mac_to_bytes mac_to_bytes 0 \
        16.42.179.76.213.110 10:2a:b3:4c:d5:6e
    run_test mac_to_bytes_upper mac_to_bytes 0 \
        16.42.179.76.213.110 10:2A:b3:4C:d5:6E
    run_test mac_to_bytes_upper mac_to_bytes 0 \
        16.42.179.76.213.110 10:2A:B3:4C:D5:6E
    run_test mac_to_bytes_no_delim mac_to_bytes 0 \
        16.42.179.76.213.110 102ab34cd56e
    run_test mac_to_bytes_delim1 mac_to_bytes 0 \
        16.42.179.76.213.110 1-0-2-a-b-3-4-c-d-5-6-e

    run_test mac_is_bcast_f_0 mac_is_bcast 1 '' 00:00:00:00:00:00
    run_test mac_is_bcast_f_1 mac_is_bcast 1 '' ff:00:00:00:00:00
    run_test mac_is_bcast_t mac_is_bcast 0 '' ff:ff:ff:ff:ff:ff

    run_test mac_bool_bcast_f_0 mac_bool_bcast 0 false 00:00:00:00:00:00
    run_test mac_bool_bcast_f_1 mac_bool_bcast 0 false ff:00:00:00:00:00
    run_test mac_bool_bcast_t mac_bool_bcast 0 true ff:ff:ff:ff:ff:ff

    run_test mac_is_mcast_f_0 mac_is_mcast 1 '' 00:00:00:00:00:00
    run_test mac_is_mcast_f_1 mac_is_mcast 1 '' 0e:00:00:00:00:00
    run_test mac_is_mcast_t_1 mac_is_mcast 0 '' 01:00:00:00:00:00
    run_test mac_is_mcast_f_2 mac_is_mcast 1 '' fe:a0:1b:cd:34:ef
    run_test mac_is_mcast_t_2 mac_is_mcast 0 '' 01:a0:1b:cd:34:ef
    run_test mac_is_mcast_t_ff mac_is_mcast 0 '' ff:ff:ff:ff:ff:ff

    run_test mac_bool_mcast_f_0 mac_bool_mcast 0 false 00:00:00:00:00:00
    run_test mac_bool_mcast_f_1 mac_bool_mcast 0 false 0e:00:00:00:00:00
    run_test mac_bool_mcast_t_1 mac_bool_mcast 0 true 01:00:00:00:00:00
    run_test mac_bool_mcast_f_2 mac_bool_mcast 0 false fe:a0:1b:cd:34:ef
    run_test mac_bool_mcast_t_2 mac_bool_mcast 0 true 01:a0:1b:cd:34:ef
    run_test mac_bool_mcast_t_ff mac_bool_mcast 0 true ff:ff:ff:ff:ff:ff

    run_test mac_is_universal_t_0 mac_is_universal 0 '' 00:00:00:00:00:00
    run_test mac_is_universal_f_0 mac_is_universal 1 '' 02:00:00:00:00:00
    run_test mac_is_universal_t_1 mac_is_universal 0 '' 0d:00:00:00:00:00
    run_test mac_is_universal_f_1 mac_is_universal 1 '' 0f:00:00:00:00:00
    run_test mac_is_universal_t_2 mac_is_universal 0 '' fd:a0:1b:cd:34:ef
    run_test mac_is_universal_f_2 mac_is_universal 1 '' 72:a0:1b:cd:34:ef

    run_test mac_bool_universal_t_0 mac_bool_universal 0 true 00:00:00:00:00:00
    run_test mac_bool_universal_f_0 mac_bool_universal 0 false \
        02:00:00:00:00:00
    run_test mac_bool_universal_t_1 mac_bool_universal 0 true 0d:00:00:00:00:00
    run_test mac_bool_universal_f_1 mac_bool_universal 0 false \
        0f:00:00:00:00:00
    run_test mac_bool_universal_t_2 mac_bool_universal 0 true fd:a0:1b:cd:34:ef
    run_test mac_bool_universal_f_2 mac_bool_universal 0 false \
        72:a0:1b:cd:34:ef

    run_test mac_set_bits_u_m_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 '' ''
    run_test mac_set_bits_u_m_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 '' ''
    run_test mac_set_bits_u_m_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '' ''
    run_test mac_set_bits_u_mf_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 '' '1'
    run_test mac_set_bits_u_mfalse_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 '' false
    run_test mac_set_bits_u_mf_1 mac_set_bits 0 \
        02:00:00:00:00:00 03:00:00:00:00:00 '' '1'
    run_test mac_set_bits_u_mfalse_1 mac_set_bits 0 \
        02:00:00:00:00:00 03:00:00:00:00:00 '' false
    run_test mac_set_bits_u_mf_ff mac_set_bits 0 \
        fe:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '' '1'
    run_test mac_set_bits_u_mfalse_ff mac_set_bits 0 \
        fe:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '' false
    run_test mac_set_bits_u_mt_0 mac_set_bits 0 \
        01:00:00:00:00:00 00:00:00:00:00:00 '' '0'
    run_test mac_set_bits_u_mtrue_0 mac_set_bits 0 \
        01:00:00:00:00:00 00:00:00:00:00:00 '' true
    run_test mac_set_bits_u_mt_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 '' '0'
    run_test mac_set_bits_u_mtrue_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 '' true
    run_test mac_set_bits_u_mt_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '' '0'
    run_test mac_set_bits_u_mtrue_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '' true
    run_test mac_set_bits_uf_m_0 mac_set_bits 0 \
        02:00:00:00:00:00 00:00:00:00:00:00 '1' ''
    run_test mac_set_bits_ufalse_m_0 mac_set_bits 0 \
        02:00:00:00:00:00 00:00:00:00:00:00 false ''
    run_test mac_set_bits_uf_m_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 '1' ''
    run_test mac_set_bits_ufalse_m_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 false ''
    run_test mac_set_bits_uf_m_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '1' ''
    run_test mac_set_bits_ufalse_m_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff false ''
    run_test mac_set_bits_ut_m_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 '0' ''
    run_test mac_set_bits_utrue_m_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 true ''
    run_test mac_set_bits_ut_m_1 mac_set_bits 0 \
        01:00:00:00:00:00 03:00:00:00:00:00 '0' ''
    run_test mac_set_bits_utrue_m_1 mac_set_bits 0 \
        01:00:00:00:00:00 03:00:00:00:00:00 true ''
    run_test mac_set_bits_ut_m_ff mac_set_bits 0 \
        fd:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '0' ''
    run_test mac_set_bits_utrue_m_ff mac_set_bits 0 \
        fd:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff true ''
    run_test mac_set_bits_uf_mf_0 mac_set_bits 0 \
        02:00:00:00:00:00 00:00:00:00:00:00 '1' '1'
    run_test mac_set_bits_uf_mf_1 mac_set_bits 0 \
        02:00:00:00:00:00 03:00:00:00:00:00 '1' '1'
    run_test mac_set_bits_uf_mf_ff mac_set_bits 0 \
        fe:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '1' '1'
    run_test mac_set_bits_uf_mt_0 mac_set_bits 0 \
        03:00:00:00:00:00 00:00:00:00:00:00 '1' '0'
    run_test mac_set_bits_uf_mt_1 mac_set_bits 0 \
        03:00:00:00:00:00 03:00:00:00:00:00 '1' '0'
    run_test mac_set_bits_uf_mt_ff mac_set_bits 0 \
        ff:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '1' '0'
    run_test mac_set_bits_ut_mf_0 mac_set_bits 0 \
        00:00:00:00:00:00 00:00:00:00:00:00 '0' '1'
    run_test mac_set_bits_ut_mf_1 mac_set_bits 0 \
        00:00:00:00:00:00 03:00:00:00:00:00 '0' '1'
    run_test mac_set_bits_ut_mf_ff mac_set_bits 0 \
        fc:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '0' '1'
    run_test mac_set_bits_ut_mt_0 mac_set_bits 0 \
        01:00:00:00:00:00 00:00:00:00:00:00 '0' '0'
    run_test mac_set_bits_ut_mt_1 mac_set_bits 0 \
        01:00:00:00:00:00 03:00:00:00:00:00 '0' '0'
    run_test mac_set_bits_ut_mt_ff mac_set_bits 0 \
        fd:ff:ff:ff:ff:ff ff:ff:ff:ff:ff:ff '0' '0'
}

# Test the test environment
test_test()
{
    run_test true true 0 ''
    run_test false false 1 ''
    run_test echo echo 0 'hello world' hello world
}

# Temporary tests
test_tmp()
{
    :
}

# List of test suites (separated by whitespace)
TEST_SUITES='bytes ip ipv4 ipv6 mac test tmp'

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

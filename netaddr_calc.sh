# Include this file into a shell (/bin/sh) script by
# . netaddr_calc.sh

# In documentation comments of functions, P = parameters, O = stdout,
# E = stderr, R = return value (exit status, 0 if unspecified)

# Boolean values use the reverted shell logic true=0, false=1.

### Operations on IPv4 addresses #############################################

# An IPv4 address is represented in the usual format of 4 decimal numbers
# delimited by '.' characters.

# ipv4_from_bytes BYTES
# Convert a sequence of bytes to an IPv4 address.
# P: BYTES = a sequence of bytes
# O: BYTES converted to an IPv4 address
ipv4_from_bytes()
{
    echo "$1"
}

# ipv4_to_bytes IP
# Convert an IPv4 address to a sequence of bytes.
# P: IP = an IPv4 address
# O: IP as a sequence of bytes
ipv4_to_bytes()
{
    echo "$1"
}

# ipv4_bits2mask BITS
# Convert a number of bits to a bitmask
# P: BITS = number of initial bits
# O: an with initial BITS bits set to 1, remaining bits set to 0
ipv4_bits2mask()
{
    bytes_bits2mask 4 $1
}

# ipv4_invert IP
# Invert all bits of an IPv4 address
# P: IP = IPv4 address
# O: IP with all bits inverted
ipv4_invert()
{
    bytes_invert $1
}

# ipv4_and IP1 IP2
# Combine two IPv4 addresses by bitwise AND
# P: IP1, IP2 = IPv4 addresses
# O: addresses combined
ipv4_and()
{
    bytes_and $1 $2
}

# ipv4_or IP1 IP2
# Combine two IPv4 addresses by bitwise OR
# P: IP1, IP2 = IPv4 addresses
# O: addresses combined
ipv4_or()
{
    bytes_or $1 $2
}

# ipv4_combine NET MASK IP
# Combines a network address and a local part of an address into a single IPv4
# address
# P: NET = an IPv4 address of a network (only bits in MASK are significant)
#    MASK = a netmask for selecting significant bits from NET and IP; it is
#           a full mask, not a number of bits (use ipv4_bits2mask for a number
#           of bits)
#    IP = a local IPv4 address (only bits not in MASK are significant)
ipv4_combine()
{
    local net mask ip
    net="$1"
    mask="$2"
    ip="$3"
    net=`bytes_and $net $mask`
    mask=`bytes_invert $mask`
    ip=`bytes_and $ip $mask`
    bytes_or $net $ip
}

### Operations on IPv6 addresses #############################################

# ipv6_from_bytes BYTES
# Convert a sequence of bytes to an IPv6 address.
# P: BYTES = a sequence of bytes
# O: BYTES converted to an IPv6 address
ipv6_from_bytes()
{
    : # TODO
}

# ipv6_to_bytes IP
# Convert an IPv6 address to a sequence of bytes.
# P: IP = an IPv6 address
# O: IP as a sequence of bytes
ipv6_to_bytes()
{
    local ip1 ip2 bytes1 bytes2 n1 n2 add
    ip1=`ipv6_lladdr2addr "$1"`
    ip2=''
    case "$ip1" in
        *::*)
            ip2=${ip1#*::}
            ip1=${ip1%::*}
            ;;
    esac
    read n1 bytes1 <<EOF
`_ipv6_part_to_bytes "$ip1"`
EOF
    read n2 bytes2 <<EOF
`_ipv6_part_to_bytes "$ip2"`
EOF
    add=$((16-n1-n2))
    while [ $add -gt 0 ]; do
        bytes1="$bytes1.0"
        add=$((add-1))
    done
    bytes1="$bytes1$bytes2"
    echo ${bytes1#.}
}

# ipv6_lladdr2addr IP
# Remove scope id from an link-local IPv6 address.
# P: IP = an IPv6 address
# O: IP without trailing '%' and a scope id; IP unchanged if it does not
#    contain a scope id
ipv6_lladdr2addr()
{
    echo ${1%\%*}
}

# ipv6_lladdr2scope IP
# Get a scope id from an link-local IPv6 address.
# P: IP = an IPv6 address with optional '%scope'
# O: the scope id (a part of IP after '%'); the empty string if IP does not
#    contain a scope id
ipv6_lladdr2scope()
{
    case "$1" in
        *%*) echo ${1#*%};;
        *) echo '';;
    esac
}

### Operations on MAC (Ethernet) addresses ###################################

# mac_from_bytes BYTES
# Converts a sequence of bytes to a MAC address. For other output formats, use
# bytes_to_hex.
# P: BYTES = a sequence of bytes
# O: BYTES converted to lowercase hexadecimal with bytes delimited by ':'
mac_from_bytes()
{
    bytes_to_hex "$1" '' 'lower' ':' ''
}

# mac_to_bytes MAC
# Convert a MAC address to a sequence of bytes.
# P: MAC = a MAC address, upper or lowercase, with any delimiters between
#          digits or bytes
# O: MAC converted to a sequence of bytes
mac_to_bytes()
{
    bytes_from_hex "$1"
}

# mac_is_bcast MAC
# Test if a MAC address is broadcast.
# P: MAC = a MAC address (in any format accepted by mac_to_bytes)
# R: 0 if MAC is a broadcast address, 1 otherwise
mac_is_bcast()
{
    _mac_is_mask "$1" 255.255.255.255.255.255
}

# mac_is_mcast MAC
# Test if a MAC address is multicast.
# P: MAC = a MAC address (in any format accepted by mac_to_bytes)
# R: 0 if MAC is a multicast (including broadcast) address, 1 otherwise
mac_is_mcast()
{
    _mac_is_mask "$1" 1.0.0.0.0.0
}

# mac_is_universal MAC
# Test if a MAC address is universally or locally administered.
# P: MAC = a MAC address (in any format accepted by mac_to_bytes)
# R: 0 if MAC is a universally administered, 1 if locally administered
mac_is_universal()
{
    ! _mac_is_mask "$1" 2.0.0.0.0.0
}

# mac_set_bits MAC UNIVERSAL MCAST
# Set special bits in a MAC address.
# P: MAC = a MAC address (in any format accepted by mac_to_bytes)
#    UNIVERSAL = sets the address as universally (0) or locally (1)
#                administered; other values do not modify the universal/local
#                bit
#    MCAST = sets the address as multicast (0) or unicast (1); other values
#            do not modify the multicast/unicast bit
# O: the modified MAC address (in format of mac_from_bytes)
mac_set_bits()
{
    local mac u m
    mac="$1"
    u="$2"
    m="$3"
    mac=`mac_to_bytes "$mac"`
    case "$u" in
        0) mac=`bytes_and $mac 253.255.255.255.255.255`;;
        1) mac=`bytes_or $mac 2.0.0.0.0.0`;;
    esac
    case "$m" in
        0) mac=`bytes_or $mac 1.0.0.0.0.0`;;
        1) mac=`bytes_and $mac 254.255.255.255.255.255`;;
    esac
    echo `mac_from_bytes $mac`
}

### IP/MASK pair #############################################################

# ip_addrmask2addr ADDRMASK
# Get the IP (v4/6) address from an "IP/MASK" pair.
# P: ADDRMASK = address/mask
# O: address
ip_addrmask2addr()
{
    echo ${1%/*}
}

# ip_addrmask2mask ADDRMASK
# Get the IP (v4/6) mask from an "IP/MASK" pair.
# P: ADDRMASK = address/mask
# O: mask
ip_addrmask2mask()
{
    echo ${1#*/}
}

### Operations on sequences of bytes #########################################

# Functions working with sequences of bytes, written as decimal numbers
# delimited by '.'

# bytes_from_hex HEX
# Convert a hexadecimal number, upper or lower case, with optional '0x' prefix
# and with separators (any non-hexdigit characters) between any digits.
bytes_from_hex()
{
    local hex result c tail byte
    hex="$1"
    hex=${hex#0[Xx]}
    result=''
    byte=''
    while [ -n "$hex" ]; do
        tail=${hex#?}
        c=${hex%$tail}
        hex="$tail"
        case "$c" in
            [0-9A-Fa-f]) byte="$byte$c";;
        esac
        if [ ${#byte} = 2 -o -z "$hex" ]; then
            byte="0x$byte"
            result="$result.$((byte))"
            byte=''
        fi
    done
    echo "${result#.}"
}

# bytes_to_hex BYTES PREFIX UPPER DELIM2 DELIM1
# Covert a sequence of bytes to a hexadecimal number.
# P: BYTES = a sequence of bytes
#    PREFIX = a prefix of result, usually '' (empty), '0x', or '0X'
#    UPPER = use uppercase hexadecimal digits if UPPER starts with 'U' or 'u';
#            use lowercase otherwise
#    DELIM2 = a delimiter between bytes
#    DELIM1 = a delimiter between digits in a byte
bytes_to_hex()
{
    local bytes prefix upper delim2 delim1 result b
    bytes="$1."
    prefix="$2"
    upper="$3"
    delim2="$4"
    delim1="$5"
    result="$prefix"
    while [ -n "$bytes" ]; do
        b=${bytes%%.*}
        bytes=${bytes#*.}
        case "$upper" in
            [Uu]*) b=`printf '%X%s%X' $((b/16)) "$delim1" $((b%16))`;;
            *) b=`printf '%x%s%x' $((b/16)) "$delim1" $((b%16))`;;
        esac
        result="$result$delim2$b"
    done
    echo "${result#$delim2}"
}

# bytes_bits2mask BYTES BITS
# Convert a number of bits to a bitmask
# P: BYTES = number of bytes in the result
#    BITS = number of initial bits
# O: a sequences of BYTES bytes with initial BITS bits set to 1, remaining bits
#    set to 0
bytes_bits2mask()
{
    local bytes bits i mask
    bytes="$1"
    bits="$2"
    i=0
    mask=''
    while [ $i -lt $bytes ]; do
        if [ $bits -ge 8 ]; then
            mask="$mask.255"
            bits=$((bits-8))
        elif [ $bits = 0 ]; then
            mask="$mask.0"
        else
            mask="$mask.$((255>>(8-bits)<<(8-bits)))"
            bits=0
        fi
        i=$((i+1))
    done
    echo ${mask#.}
}

# bytes_invert BYTES
# Invert all bits of a sequence of bytes
# P: BYTES = a sequence of bytes
# O: BYTES with all bit values inverted
bytes_invert()
{
    local bytes
    bytes="$1"
    _bytes_apply _bytes_op_invert $bytes $bytes
}

# bytes_and BYTES1 BYTES2
# Apply bitwise AND to corresponding bits of two sequences of bytes
# P: BYTES1, BYTES2 = input sequences of the same number of bytes
# O: result of bitwise AND
bytes_and()
{
    local bytes1 bytes2
    bytes1="$1"
    bytes2="$2"
    _bytes_apply _bytes_op_and $bytes1 $bytes2
}

# bytes_or BYTES1 BYTES2
# Apply bitwise OR to corresponding bits of two sequences of bytes
# P: BYTES1, BYTES2 = input sequences of the same number of bytes
# O: result of bitwise OR
bytes_or()
{
    local bytes1 bytes2
    bytes1="$1"
    bytes2="$2"
    _bytes_apply _bytes_op_or $bytes1 $bytes2
}

### Internal functions #######################################################

_bytes_op_invert()
{
    echo $((255^$1))
}

_bytes_op_and()
{
    echo $(($1&$2))
}

_bytes_op_or()
{
    echo $(($1|$2))
}

_bytes_apply()
{
    local op bytes1 bytes2 result b1 b2
    op="$1"
    bytes1="$2."
    bytes2="$3."
    result=""
    while [ -n "$bytes1" ]; do
        b1=${bytes1%%.*}
        bytes1=${bytes1#*.}
        b2=${bytes2%%.*}
        bytes2=${bytes2#*.}
        result="$result.`$op $b1 $b2`"
    done
    echo ${result#.}
}

_ipv6_part_to_bytes()
{
    local ip bytes n i b
    ip="$1"
    bytes=''
    n=0
    if [ -n "$ip" ]; then
        ip="$ip:"
    fi
    while [ -n "$ip" ]; do
        i=0x${ip%%:*}
        ip=${ip#*:}
        bytes="$bytes.$((i/256)).$((i%256))"
        n=$((n+2))
    done
    echo "$n $bytes"
}

_mac_is_mask()
{
    local mac mask
    mac="$1"
    mask="$2"
    mac=`mac_to_bytes "$mac"`
    mac=`bytes_and "$mac" "$mask"`
    test "$mac" = "$mask"
}

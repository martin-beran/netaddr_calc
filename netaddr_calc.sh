# Include this file into a shell (/bin/sh) script by
# . netaddr_calc.sh

# In documentation comments of functions, P = parameters, O = stdout,
# E = stderr, R = return value (exit status, 0 if unspecified)

### Operations on IPv4 addresses #############################################

# An IPv4 address is represented in the usual format of 4 decimal numbers
# delimited by '.' characters.

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

### Operations on IPv6 addresses #############################################

### Operations on MAC (Ethernet) addresses ###################################

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

# Auxiliary functions working with sequences of bytes, written as decimal
# numbers delimited by '.'

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

# Auxiliary functions for bytes_invert, bytes_and, bytes_or

bytes_op_invert()
{
    echo $((255^$1))
}

bytes_op_and()
{
    echo $(($1&$2))
}

bytes_op_or()
{
    echo $(($1|$2))
}

bytes_apply()
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

# bytes_invert BYTES
# Invert all bits of a sequence of bytes
# P: BYTES = a sequence of bytes
# O: BYTES with all bit values inverted
bytes_invert()
{
    local bytes
    bytes="$1"
    bytes_apply bytes_op_invert $bytes $bytes
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
    bytes_apply bytes_op_and $bytes1 $bytes2
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
    bytes_apply bytes_op_or $bytes1 $bytes2
}

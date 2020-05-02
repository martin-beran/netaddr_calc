# Include this file into a shell (/bin/sh) script by
# . netaddr_calc.sh

### IP/MASK pair #############################################################

# Get the IP (v4/6) address from an "IP/MASK" pair.
# P: address+mask
# R: address
ip_addrmask2addr()
{
    echo ${1%/*}
}

# Get the IP (v4/6) mask from an "IP/MASK" pair.
# P: address+mask
# R: mask
ip_addrmask2mask()
{
    echo ${1#*/}
}

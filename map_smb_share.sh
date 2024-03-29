#!/bin/bash

# GitRepo: https://github.com/macmule/MapDrivesAndPrintersBasedOnADGroupMembershipOnOSX
# Repurposed into Bash script by Lance Stephens 5-27-16
# Need to be run as root (i.e., sudo bash -vx map_smb_share.sh)


# loggedInUser=$(whoami)
loggedInUser=$(ls -l /dev/console | cut -d " " -f 4)
echo "$loggedInUser"

# Get the Users account UniqueID
accountType=$(dscl . -read /Users/$loggedInUser | grep UniqueID | cut -c 11-)
# accountType=$(dscl . -read /Users/$loggedInUser | grep UniqueID | cut -c 11-)
echo "$accountType"

# Get the nodeName from the Users account
nodeName=$(dscl . -read /Users/$loggedInUser | awk '/^OriginalNodeName:/,/^Password:/' | head -2 | tail -1 | cut -c 2-)
# nodeName=$(dscl . -read /Users/$loggedInUser | awk '/^OriginalNodeName:/,/^Password:/' | head -2 | tail -1 | cut -c 2-)
echo "$nodeName"

# Get the Users group membership from AD
ADGroups=$(dscl $nodeName -read /Users/$loggedInUser | awk '/^dsAttrTypeNative:memberOf:/,/^dsAttrTypeNative:msExchHomeServerName:/')
# ADGroups=$(dscl $nodeName -read /Users/$loggedInUser | awk '/^dsAttrTypeNative:memberOf:/,/^dsAttrTypeNative:msExchHomeServerName:/')
echo "$ADGroups"

# Checks to see if account is an AD Account, if its not exit
if [ "$accountType" -lt "1000" ]; then
	exit 1
fi

# Checks Group Membership for ADGroups contains user & if they -- are in the correct groups, mount shares.
if grep -q HPS <<<$nodeName; then
    osascript -e 'mount volume "smb://hplnmdtbldp01/maclogs"'
else
	echo "No dice"
fi

# Call syslogs.sh
# Commented out for JSS
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo $DIR
# bash -vx $DIR/syslogs.sh

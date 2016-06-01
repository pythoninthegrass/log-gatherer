# More information: http://macmule.com/2011/09/08/how-to-map-drives-printers-based-on-ad-group-membership-on-osx/
# GitRepo: https://github.com/macmule/MapDrivesAndPrintersBasedOnADGroupMembershipOnOSX
# License: http://macmule.com/license/
# Repurposed into Bash script by Lance Stephens 5-27-16


loggedInUser=$(whoami)
echo "$loggedInUser"

# Get the Users account UniqueID
accountType=$(dscl . -read /Users/`whoami` | grep UniqueID | cut -c 11-)
# accountType=$(dscl . -read /Users/$loggedInUser | grep UniqueID | cut -c 11-)
echo "$accountType"

# Get the nodeName from the Users account
nodeName=$(dscl . -read /Users/`whoami` | awk '/^OriginalNodeName:/,/^Password:/' | head -2 | tail -1 | cut -c 2-)
# nodeName=$(dscl . -read /Users/$loggedInUser | awk '/^OriginalNodeName:/,/^Password:/' | head -2 | tail -1 | cut -c 2-)
echo "$nodeName"

# Get the Users group membership from AD
ADGroups=$(dscl $nodeName -read /Users/`whoami` | awk '/^dsAttrTypeNative:memberOf:/,/^dsAttrTypeNative:msExchHomeServerName:/')
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
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# echo $DIR
bash -vx $DIR/syslogs.sh

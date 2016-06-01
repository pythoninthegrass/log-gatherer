#!/bin/bash


# Diags Logs - Abbreviated
# Avoids running sysdiagnose creating a 20+ MB file.

loggedInUser=$(whoami)
HOST=$(hostname)
D=$(date +%Y%m%d-%H%M)

# One folder to rule them all
if [ ! -e "/usr/local/logs/" ]; then
    sudo mkdir -p /usr/local/logs/
fi

# System Profiler
system_profiler > /usr/local/logs/system_profiler_"$D".log

# Copy diags reports
mkdir -p /usr/local/logs/DiagnosticReports_"$D" && cp -r ~/Library/Logs/DiagnosticReports/ /usr/local/logs/DiagnosticReports_*

# Copy console log
syslog -C > /usr/local/logs/syslog_"$D".log

# Power settings
pmset -g everything > /usr/local/logs/pmset_"$D".log

## Subroutine for copying kernel panics from last 3 days
# Check for existing Kernel Diags folder in /usr/local/logs/
if [ ! -e "/usr/local/logs/KernelDiagnosticReports_$D/" ]; then
    sudo mkdir -p /usr/local/logs/KernelDiagnosticReports_$D/
fi
# Copy all kernel panics from last 3 days
cd /Library/Logs/DiagnosticReports/
find . -name "*.*" -mtime -3 -exec cp -r {} /usr/local/logs/KernelDiagnosticReports_$D \;
sudo chown -Rv $loggedInUser /usr/local/logs/KernelDiagnosticReports_*

# JSS logs
if [ -f "/var/log/jamf.log" ]; then
    cp /var/log/jamf.log /usr/local/logs/jamf_$D.log
fi

# Compress contents
cd /usr/local/logs/
tar -zcvf /usr/local/"$HOST"_logs_"$D".tar.gz *
cd /usr/local/ && sudo chown -Rv $loggedInUser *.tar.gz

# Copy logs to maclogs share
if [ ! -e /Volumes/maclogs/"$HOST"/"$D"/ ]; then
    sudo mkdir -p /Volumes/maclogs/"$HOST"/"$D"/
fi
cp /usr/local/"$HOST"_logs_"$D".tar.gz /Volumes/maclogs/"$HOST"/"$D"/

# Unmount /Volumes/maclogs/
if mount | grep "on /Volumes/*maclogs*" > /dev/null; then
    sudo diskutil unmount /Volumes/maclogs/
else
    echo "/Volumes/maclogs not mounted"
fi

# Inform user of success
echo "Operations have completed successfully."

# Destroy this script!
# srm "$0"

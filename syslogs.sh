#!/usr/bin/env bash


# Diags Logs - Abbreviated
# Bash script by Lance Stephens 6-2-16
# Avoids running sysdiagnose creating a 20+ MB file.

# loggedInUser=$(whoami)
loggedInUser=$(ls -l /dev/console | cut -d " " -f 4)
HOST=$(hostname)
logTime=$(date +%Y-%m-%d:%H:%M:%S)
installLog="/tmp/syslogs_$logTime.log"
exec &> >(tee -a "$installLog")

# One folder to rule them all
if [ ! -e "/usr/local/logs/" ]; then
    sudo mkdir -p /usr/local/logs/
    sudo chown -Rv $loggedInUser /usr/local/logs/
fi

# System Profiler
system_profiler > /usr/local/logs/system_profiler_"$logTime".log

# Copy diags reports
mkdir -p /usr/local/logs/DiagnosticReports_"$logTime" && cp -r ~/Library/Logs/DiagnosticReports/ /usr/local/logs/DiagnosticReports_*

# Copy console log
syslog -C > /usr/local/logs/syslog_"$logTime".log

# Power settings
pmset -g everything > /usr/local/logs/pmset_"$logTime".log

## Subroutine for copying kernel panics from last 3 days
# Check for existing Kernel Diags folder in /usr/local/logs/
if [ ! -e "/usr/local/logs/KernelDiagnosticReports_$logTime/" ]; then
    sudo mkdir -p /usr/local/logs/KernelDiagnosticReports_$logTime/
fi

# Copy all kernel panics from last 3 days
cd /Library/Logs/DiagnosticReports/
find . -name "*.*" -mtime -3 -exec cp -r {} /usr/local/logs/KernelDiagnosticReports_$logTime \;
sudo chown -Rv $loggedInUser /usr/local/logs/KernelDiagnosticReports_*

# JSS logs
if [ -f "/var/log/jamf.log" ]; then
    cp /var/log/jamf.log /usr/local/logs/jamf_$logTime.log
fi

# Compress contents
cd /usr/local/logs/
tar -zcvf /usr/local/"$HOST"_logs_"$logTime".tar.gz *
cd /usr/local/ && sudo chown -Rv $loggedInUser *.tar.gz

# Copy logs to maclogs share
if [ ! -e "/Volumes/*maclogs*"/"$HOST"/"$logTime"/ ]; then
    sudo mkdir -p /Volumes/maclogs/"$HOST"/"$logTime"/
fi
cp /usr/local/"$HOST"_logs_"$logTime".tar.gz /Volumes/maclogs/"$HOST"/"$logTime"/

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

exit 0

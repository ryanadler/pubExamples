#!/bin/bash
##
# This script was meant as a method of making sure the syslog files and folders on your reciever system don't get too out of control
##

## Assumptions: syslog-ng writes to /opt/syslog , you've already created /opt/storage, and have enough room on your disk to accomodate relevant files

# Stat: get the number of files that will be packed up
fileCountPRE=$(/bin/find '/opt/syslog' -type f -name '*.log' -cmin +60 -exec ls {} \; | wc -l)

# Action: Make directories where necessary to keep organization
find /opt/syslog -type d | sed 's/\/opt\/syslog/\/opt\/storage/g' | xargs -I{} mkdir -p "{}"

# Action: Move files older than 60 minutes
for entry in $(/bin/find '/opt/syslog' -type f -name '*.log' -cmin +60) ; do
  originalPath=$(echo $entry)
  newPath=$(echo $entry | sed 's/\/opt\/syslog/\/opt\/storage/g')
  mv $originalPath $newPath
done

# Stat: get the number of files that were moved and about to be compressed
fileCountPOST=$(/bin/find '/opt/storage' -type f -name '*.log' -exec ls {} \; | wc -l)

# Action: Copmress Files
/bin/find '/opt/storage' -type f -name '*.log' -exec gzip -9 {} \;

# Log: Write out a message about the actions taken
logger "Housekeeping - syslog files compressed for storage - Moved: $fileCountPRE , Compressed: $fileCountPOST"

# Splunk alerts can be created for when PRE and POST aren't close to alert on housekeeping issues.

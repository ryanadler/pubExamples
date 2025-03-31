#!/bin/bash

# change directories
 cd /opt/splunk/etc/apps/200_org_customizations/bin

# Initial Cleanup

rm -f *.tmp fqdns

# Splunk Btool Outputs and Normalize Results
splunk btool outputs list | grep inputs | grep splunkcloud | grep -E "^server" | sed 's/, /\n/g' | sed 's/server = //g' | sed 's/:9997//g' | sort | uniq > fqdns

# timestamp files
stamp=$(date +%s)

# Read fqdns and for loop to assign IP address for each and report
for entry in $(cat fqdns); do
        touch $entry.tmp
        echo "$stamp - $HOSTNAME" > $entry.tmp
        echo "$entry - " >> $entry.tmp
        nslookup $entry | grep Address | grep -v "#53" >> $entry.tmp
        echo "" >> $entry.tmp
done

# cleanup
rm -f fqdns

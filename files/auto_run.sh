#!/bin/bash

# Ugh, bash. What can I say, I need a bit of pain occasionally?

/usr/local/munki/managedsoftwareupdate --auto
/bin/rm /Library/LaunchDaemons/org.munki.auto_run.plist
/bin/rm /usr/local/munki/auto_run.sh

exit 0
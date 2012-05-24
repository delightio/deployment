#!/bin/sh
# This script builds and deploys the latest version of the gesturedrawer.

ROOT_UID="0"

# Check that user has sudo
if [ "$UID" -ne "$ROOT_UID" ] ; then
	echo "This script needs sudo to run."
	exit 1
fi

# Get the latest code
cd /Users/delight/code/delight.web
git pull || { echo "git pull failed, aborting"; exit 2; }
cd /Users/delight/code/gesturedraw
git pull || { echo "git pull failed, aborting"; exit 2; }

# Build it
xcodebuild -target gesturedrawer -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }

# Make backup of old gesturedrawer and deploy the new one
echo "Stopping daemon..."
launchctl unload /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist || { echo "Stopping daemon failed, aborting"; exit 2; }
mkdir -p /usr/local/backup/gesturedrawer
mv /usr/local/bin/gesturedrawer /usr/local/backup/gesturedrawer/gesturedrawer_`date '+%Y-%m-%d-%H%M%S'`
mv build/Release/gesturedrawer /usr/local/bin/
chown delight:staff /usr/local/bin/gesturedrawer
echo "Starting daemon..."
launchctl load /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist
echo "Success!"


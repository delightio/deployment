#!/bin/sh
# This script builds and deploys the latest version of the gesturedrawer.
# Usage: deploy_gesturedrawer <delight.web branch> <gesturedrawer branch>

# Check that user is delight since it messes up permissions otherwise
if [ "$USER" != "delight" ] ; then
	echo "This script must be run as delight user."
	exit 1
fi

web_branch=${1-master}
draw_branch=${2-master}

# Get the latest code
cd /Users/delight/code/delight.web
git checkout $web_branch || { echo "can't switch to delight.web branch $web_branch"; exit 2; }
git pull || { echo "git pull failed, aborting"; exit 2; }
cd /Users/delight/code/gesturedraw
git checkout $draw_branch || { echo "can't switch to gesturedrawer branch $draw_branch"; exit 2; }
git pull || { echo "git pull failed, aborting"; exit 2; }

# Build it
xcodebuild -target gesturedrawer -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }

# Make backup of old gesturedrawer and deploy the new one
echo "Stopping daemon..."
sudo launchctl unload /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist || { echo "Stopping daemon failed, aborting"; exit 2; }
mkdir -p /usr/local/backup/gesturedrawer
mv /usr/local/bin/gesturedrawer /usr/local/backup/gesturedrawer/gesturedrawer_`date '+%Y-%m-%d-%H%M%S'`
mv build/Release/gesturedrawer /usr/local/bin/
chown delight:staff /usr/local/bin/gesturedrawer
echo "Starting daemon..."
sudo launchctl load /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist
echo "Success!"


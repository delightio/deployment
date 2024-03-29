#!/bin/sh
# This script builds and deploys the latest version of the gesturedrawer.

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
git pull || { echo "delight.web: git pull failed, aborting"; exit 2; }

# bundle install
bundle install || { echo "delight.web: bundle install failed, aborting"; exit 2; }

# run db migration
bundle exec rake db:migrate || { echo "delight.web: bundle exec rake db:migrate failed, aborting"; exit 2; }

# qtrotate
cd /Users/delight/code/qtrotate
git pull || { echo "qtrotate: git pull failed, aborting"; exit 2; }
cp qtrotate.py /usr/local/bin/
chown delight:staff /usr/local/bin/qtrotate.py

# Build JSON converters
cd /Users/delight/code/jsonconverters
git pull || { echo "jsonconverters: git pull failed, aborting"; exit 2; }
xcodebuild -target touchconvert -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }
xcodebuild -target eventconvert -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }
mkdir -p /usr/local/backup/jsonconverters
mv /usr/local/bin/touchconvert /usr/local/backup/jsonconverters/touchconvert_`date '+%Y-%m-%d_%H:%M:%S'`
mv /usr/local/bin/eventconvert /usr/local/backup/jsonconverters/eventconvert_`date '+%Y-%m-%d_%H:%M:%S'`
mv build/Release/touchconvert /usr/local/bin
mv build/Release/eventconvert /usr/local/bin

cd /Users/delight/code/gesturedraw
git checkout $draw_branch || { echo "can't switch to gesturedrawer branch $draw_branch"; exit 2; }
git pull || { echo "git pull failed, aborting"; exit 2; }

# Build it
xcodebuild -target gesturedrawer -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }
xcodebuild -target majororientation -configuration Release -sdk macosx10.7 clean build || { echo "Build failed, aborting"; exit 2; }

# Make backup of old gesturedrawer and deploy the new one
echo "Stopping daemon..."
sudo launchctl unload /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist || { echo "Stopping daemon failed, aborting"; exit 2; }

mkdir -p /usr/local/backup/gesturedrawer
mv /usr/local/bin/gesturedrawer /usr/local/backup/gesturedrawer/gesturedrawer_`date '+%Y-%m-%d_%H:%M:%S'`
mv build/Release/gesturedrawer /usr/local/bin/
chown delight:staff /usr/local/bin/gesturedrawer

# major orientation
mv /usr/local/bin/majororientation /usr/local/backup/gesturedrawer/majororientation_`date '+%Y-%m-%d_%H:%M:%S'`
mv build/Release/majororientation /usr/local/bin/
chown delight:staff /usr/local/bin/majororientation

echo "Starting daemon..."
cd /Users/delight/code/deployment
sudo cp com.pipely.DelightVideoProcessor.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/com.pipely.DelightVideoProcessor.plist || { echo "Starting daemon failed. That's not good!"; exit 2; }
echo "Success!"


#!/bin/sh

# Chrome Web Installer
# Copyright © 2013 Geoff Stokes

# Downloads and sandboxes (using chrome-installer) the latest Chrome build from any of the channels.

echo Installing...

# Temporary files go here
tmpdir="/tmp/multichrome"

# Choose our release channel
case "$1" in
	beta)
		URL="https://dl.google.com/chrome/mac/beta/GoogleChrome.dmg"
		;;
	dev)
		URL="https://dl.google.com/chrome/mac/dev/GoogleChrome.dmg"
		;;
	*)
		URL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
		;;
esac

# Extract filename
FILE=$(basename $URL)
echo Retrieving \"$URL\"...

# Make directories
mkdir -p $tmpdir &&
cd $tmpdir

# Fetch disk image
curl --progress-bar --location --continue-at - $URL --remote-name

cd -

# Defer to Chrome Installer
./chrome-installer.sh $tmpdir/$FILE && rm $tmpdir/$FILE

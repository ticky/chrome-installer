#!/bin/sh

# Chrome Installer
# Copyright 2013 Geoff Stokes

# Creates an AppleScript-based launcher bundle for Chrome.
# Prevents auto-updates by restoring the app bundle to its original state (from the disk image) every launch.
# Also forces Chrome versions to use their own distinct profile directory.

# Installed launcher bundles go here
outdir="/Applications/Google Chromes"

# Extract filename
targetFile=$1
targetFileName=$(basename $1)
echo Installing Chrome from \"$targetFileName\"...

# Mount disk image
hdiutil attach -quiet -nobrowse $targetFile &&

# Get the version from the Application bundle
version="$(defaults read /Volumes/Google\ Chrome/Google\ Chrome.app/Contents/Info.plist CFBundleShortVersionString)"

if [ ! $version ]; then
	hdiutil detach -quiet "/Volumes/Google Chrome"
	echo There was an error installing Chrome.
	exit 1
fi

# Remove the existing app if it's there
if [ -d "$outdir/Google Chrome $version.app" ]; then
	rm -rf "$outdir/Google Chrome $version.app"
fi

# Create a launcher AppleScript Application bundle using `osacompile`
echo "do shell script \"bundlePath=\" & (quoted form of the POSIX path of (path to me)) & \" && rm -rf \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app\\\" > /dev/null 2>&1; hdiutil mount -quiet -nobrowse \\\"\$bundlePath/Contents/Resources/googlechrome.dmg\\\" && cp -R \\\"/Volumes/Google Chrome/Google Chrome.app\\\" \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app\\\" && hdiutil detach -quiet \\\"/Volumes/Google Chrome/\\\" && \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\\\" --user-data-dir=\\\"/Users/\$USER/Library/Application Support/Google/Chrome $version\\\" > /dev/null 2>&1\"" | osacompile -o "$outdir/Google Chrome $version.app"

# Create a directory inside Resources for putting the real Application bundle in
mkdir -p "$outdir/Google Chrome $version.app/Contents/Resources/Applications"

# Put the real Application bundle inside the launcher bundle
cp -R "/Volumes/Google Chrome/Google Chrome.app" "$outdir/Google Chrome $version.app/Contents/Resources/Applications"

# Change the launcher bundle's icon to be the real Application's
cp "$outdir/Google Chrome $version.app/Contents/Resources/Applications/Google Chrome.app/Contents/Resources/app.icns" "$outdir/Google Chrome $version.app/Contents/Resources/applet.icns"

# Set the launcher bundle's icon to match the Application's
defaults write "$outdir/Google Chrome $version.app/Contents/Info" CFBundleShortVersionString "$version Launcher"

# Detach disk image
hdiutil detach -quiet "/Volumes/Google Chrome"

# Move the disk image into the launcher app, or delete it
if [ ! -f "$outdir/Google Chrome $version.app/Contents/Resources/googlechrome.dmg" ]; then
	cp $targetFile "$outdir/Google Chrome $version.app/Contents/Resources/googlechrome.dmg"
fi

echo Done.

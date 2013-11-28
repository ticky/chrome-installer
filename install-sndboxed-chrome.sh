#!/bin/sh

echo Installing Chrome...

# Temporary files go here
tmpdir="/tmp/multichrome"

# Installed launcher bundles go here
outdir="/Applications/Google Chromes"

# Choose our release channel
case "$1" in
	beta)
		URL="https://dl.google.com/chrome/mac/beta/GoogleChrome.dmg"
		;;
	dev)
		URL="https://dl.google.com/chrome/mac/dev/GoogleChrome.dmg"
		;;
	*)
		URL="http://stash.gstokes.movideo.com/googlechrome.dmg"
		#URL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
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

# Mount disk image
hdiutil attach -quiet -nobrowse $tmpdir/$FILE &&

# Get the version from the Application bundle
version="$(defaults read /Volumes/Google\ Chrome/Google\ Chrome.app/Contents/Info.plist CFBundleShortVersionString)"

if [ ! $version ]; then
	echo "Error fetching Chrome."
	hdiutil detach -quiet "/Volumes/Google Chrome"
	exit
fi

# Remove the existing app if it's there
if [ -d "$outdir/Google Chrome $version.app" ]; then
	rm -rf "$outdir/Google Chrome $version.app"
fi

# Create a launcher AppleScript Application bundle using `osacompile`
echo "do shell script \"bundlePath=\" & (quoted form of the POSIX path of (path to me)) & \" && rm -rf \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app\\\" > /dev/null 2>&1; hdiutil mount -quiet -nobrowse \\\"\$bundlePath/Contents/Resources/googlechrome.dmg\\\" && cp -R \\\"/Volumes/Google Chrome/Google Chrome.app\\\" \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app\\\" && hdiutil unmount -quiet \\\"/Volumes/Google Chrome/\\\" && \\\"\$bundlePath/Contents/Resources/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\\\" --user-data-dir=\\\"/Users/\$USER/Library/Application Support/Google/Chrome $version\\\" > /dev/null 2>&1\"" | osacompile -o "$outdir/Google Chrome $version.app"

# Create a directory inside Resources for putting the real Application bundle in
mkdir -p "$outdir/Google Chrome $version.app/Contents/Resources/Applications"

# Put the real Application bundle inside the launcher bundle
cp -R "/Volumes/Google Chrome/Google Chrome.app" "$outdir/Google Chrome $version.app/Contents/Resources/Applications"

# Change the launcher bundle's icon to be the real Application's
cp "$outdir/Google Chrome $version.app/Contents/Resources/Applications/Google Chrome.app/Contents/Resources/app.icns" "$outdir/Google Chrome $version.app/Contents/Resources/applet.icns"

# Set the launcher bundle's icon to match the Application's
defaults write "$outdir/Google Chrome $version.app/Contents/Info" CFBundleShortVersionString "$version Launcher"

# Unmount disk image
hdiutil detach -quiet "/Volumes/Google Chrome"

# Move the disk image into the launcher app, or delete it
if [ ! -f "$outdir/Google Chrome $version.app/Contents/Resources/googlechrome.dmg" ]; then
	mv $tmpdir/$FILE "$outdir/Google Chrome $version.app/Contents/Resources/googlechrome.dmg"
else
	rm $tmpdir/$FILE
fi

echo Installed Chrome $version.
 
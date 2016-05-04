# Chrome Installer

Downloads and sandboxes the latest Chrome build from any of the channels. Automatic updates are prevented, and each version writes to its own Application Support directory.

Born out of some odd support requirements (specific, old Chrome versions) at a previous job, I've finally nailed down an automated system for this, primarily out of curiosity.

## Requirements

* Mac OS X
* cURL

## Usage

Included are two shell scripts, one which can fetch and install the latest Stable, Beta or Dev build from the web, and one which allows installation from an existing downloaded DMG file.

### Web Installer

```shell
./chrome-web-installer.sh [version]
```

Where `version` is;
* 'stable' (or not specified) for the stable channel
* 'dev' for the dev channel
* 'beta' for the beta channel

### Installer

```shell
./chrome-installer.sh file
```

Where `file` is the path to a DMG file containing a version of Google Chrome.

## Behind The Scenes

The Web Installer is essentially a wrapper which fetches a DMG from Google automatically. It doesn't really do anything special in and of itself.

The Installer, however, is (if I do say so myself), pretty clever. It will;
* Create a `Google Chromes` directory inside `/Applications`
* Open the DMG and retrieve the version of Chrome contained therein
* Remove that version from `Google Chromes` if it already exists
* Create an AppleScript-based wrapper for Chrome which will;
	* Delete the previously used Chrome app bundle (to avoid automatic updates)
	* Restore the Chrome app bundle from its original installer DMG
	* Run Chrome with its own separate directory within Application Support
* Update the wrapper's icon and Version information to match the version of Chrome contained therein
* Close the DMG and copy it into the app bundle so it can be used as a backup

In essence, this means you get to run multiple versions of Chrome simultaneously, and none of their settings will conflict or cause another version to crash.

## Legal

Copyright © 2013 Jessica Stokes. Please see `license.txt`.

This project is not affiliated with Google or Chrome in any way. No portions of Chrome are distributed as part of this project.
#!/usr/bin/env bash

set -e

if ! which swift &>/dev/null; then
	echo "No swift Installed."
	exit 127
fi

BUNDLE_PATH=$(which bundle)

if [ ! $BUNDLE_PATH ]; then
	echo "No bundler Installed."
	exit 127
fi

$BUNDLE_PATH exec fastlane scan

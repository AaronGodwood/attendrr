#!/usr/bin/env bash
set -euo pipefail

BUNDLE_ID="${1:-com.example.attendr}"

if ! xcrun simctl list devices booted | grep -q Booted; then
  echo "No booted iOS Simulator found. Boot one first." >&2
  exit 1
fi

xcrun simctl privacy booted grant location "$BUNDLE_ID"

# simctl expects a single "lat,lon" token
xcrun simctl location booted set "51.379924,-2.328749"

echo "Granted location permission and set location for $BUNDLE_ID"

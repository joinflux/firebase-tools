#!/bin/bash
set -euo pipefail

# Get the latest firebase-tools version from npm
LATEST_VERSION=$(npm view firebase-tools version)

echo "latest=$LATEST_VERSION" >> "$GITHUB_OUTPUT"
echo "Latest firebase-tools version: $LATEST_VERSION"

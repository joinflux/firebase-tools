#!/bin/bash
set -euo pipefail

# Get the latest release tag, or use 0.0.0 if no releases exist
LATEST_RELEASE=$(gh release list --limit 1 --json tagName --jq '.[0].tagName' 2>/dev/null || echo "0.0.0")

# Remove 'v' prefix if present
LATEST_RELEASE=${LATEST_RELEASE#v}

echo "latest=$LATEST_RELEASE" >> "$GITHUB_OUTPUT"
echo "Latest repo release: $LATEST_RELEASE"

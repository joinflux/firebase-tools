#!/bin/bash
set -euo pipefail

NPM_VERSION="$1"
REPO_VERSION="$2"

# Releases push version pins to master; refuse to run from any other ref
if [ "${GITHUB_REF_NAME:-master}" != "master" ]; then
  echo "Refusing to release from ref '${GITHUB_REF_NAME}'. Run this workflow from master."
  exit 1
fi

echo "Comparing versions:"
echo "  npm: $NPM_VERSION"
echo "  repo: $REPO_VERSION"

if [ "$NPM_VERSION" != "$REPO_VERSION" ]; then
  echo "New version detected! Creating release for v$NPM_VERSION"

  # Commit the version pins so the release tag references the matching Docker image
  sed -i -E "s|image: \"docker://joinflux/firebase-action:[^\"]+\"|image: \"docker://joinflux/firebase-action:${NPM_VERSION}\"|" action.yaml
  sed -i -E "s|^ARG FIREBASE_VERSION=.*|ARG FIREBASE_VERSION=${NPM_VERSION}|" Dockerfile Dockerfile.alpine
  sed -i -E "s|joinflux/firebase-tools@v[0-9.]+|joinflux/firebase-tools@v${NPM_VERSION}|g" README.md

  git add action.yaml Dockerfile Dockerfile.alpine README.md
  # Skip the commit if the pins are already current (e.g. a rerun after a failed release)
  if ! git diff --cached --quiet; then
    git config user.name "github-actions[bot]"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git commit -m "chore: release v${NPM_VERSION}"
    git push origin HEAD:master
  fi

  # Create release notes
  cat > release-notes.md << EOF
## Firebase Tools v$NPM_VERSION

This release updates the firebase-tools version to v$NPM_VERSION.

### Changes
- Updated firebase-tools from v$REPO_VERSION to v$NPM_VERSION

### Docker Images
- \`joinflux/firebase-action:$NPM_VERSION\` - Regular Node.js image
- \`joinflux/firebase-action:$NPM_VERSION-alpine\` - Alpine-based image

For firebase-tools changelog, see: https://github.com/firebase/firebase-tools/releases
EOF
  
  # Create the release
  gh release create "v$NPM_VERSION" \
    --title "v$NPM_VERSION" \
    --notes-file release-notes.md
  
  echo "created=true" >> "$GITHUB_OUTPUT"
  echo "version=$NPM_VERSION" >> "$GITHUB_OUTPUT"
  echo "✅ Successfully created release v$NPM_VERSION"
else
  echo "No new version. Current version: $REPO_VERSION"
  echo "created=false" >> "$GITHUB_OUTPUT"
fi

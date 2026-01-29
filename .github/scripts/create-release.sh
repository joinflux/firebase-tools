#!/bin/bash
set -euo pipefail

NPM_VERSION="$1"
REPO_VERSION="$2"

echo "Comparing versions:"
echo "  npm: $NPM_VERSION"
echo "  repo: $REPO_VERSION"

if [ "$NPM_VERSION" != "$REPO_VERSION" ]; then
  echo "New version detected! Creating release for v$NPM_VERSION"
  
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

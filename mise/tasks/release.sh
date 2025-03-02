#!/usr/bin/env bash
#MISE description="Releases a new version of the project if needed."

set -eo pipefail

bumped_changelog_hash=$(echo -n "$(git cliff --bump --unreleased)" | shasum -a 256 | awk '{print $1}')
current_changelog_hash=$(echo -n "$(cat CHANGELOG.md)" | shasum -a 256 | awk '{print $1}')

if [ "$bumped_changelog_hash" == "$current_changelog_hash" ]; then
    echo "No releasable changes detected. Exiting earlier..."
    exit 0
fi

next_version=$(git cliff --bumped-version)

# Updating the CHANGELOG.md
git cliff --bump -o CHANGELOG.md
git add CHANGELOG.md
git commit -m "[Release] Glossia $next_version"
git tag "$next_version"
git push origin "$next_version"

release_notes=$(git cliff --latest)

PAYLOAD=$(cat <<EOF
{
  "tag_name": "$next_version",
  "name": "$next_version",
  "body": "$release_notes",
  "draft": false,
  "prerelease": false
}
EOF
)

# Make API request to create the release
RESPONSE=$(curl -s -X POST "https://codeberg.org/api/v1/repos/glossia/glossia/releases" \
  -H "Authorization: token $GLOSSIA_CODEBERG_WORKFLOWS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

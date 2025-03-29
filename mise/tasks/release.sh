#!/usr/bin/env bash
#MISE description="Releases a new version of the project if needed."

set -exo pipefail

bumped_changelog=$(git cliff --bump)
current_changelog=$(cat CHANGELOG.md)

echo "Current changelog:"
echo "$current_changelog"

echo "Bumped changelog:"
echo "$bumped_changelog"

bumped_changelog_hash=$(echo -n "$bumped_changelog" | shasum -a 256 | awk '{print $1}')
current_changelog_hash=$(echo -n "$current_changelog" | shasum -a 256 | awk '{print $1}')

if [ "$bumped_changelog_hash" == "$current_changelog_hash" ]; then
    echo "No releasable changes detected. Exiting earlier..."
    exit 0
fi

next_version=$(git cliff --bumped-version)

# Build image
if command -v podman &> /dev/null
then
    container_cmd="podman"
elif command -v docker &> /dev/null
then
    # Fallback to docker if podman is not available
    container_cmd="docker"
else
    echo "Neither podman nor docker is installed on this system."
    exit 1
fi

echo "Building image..."
image_tag="github.com/glossia/glossia:$next_version"
$container_cmd build -t $image_tag .

# Updating the CHANGELOG.md
echo "Updating CHANGELOG.md..."
git cliff --bump -o CHANGELOG.md

echo "Committing and tagging..."
git add CHANGELOG.md
git commit -m "[Release] Glossia $next_version"
git tag "$next_version"
git push origin "$next_version"

echo "Generating release notes..."
release_notes=$(git cliff --latest)

echo "Creating release..."
PAYLOAD=$(jq -n \
  --arg tag_name "$next_version" \
  --arg name "$next_version" \
  --arg body "$release_notes" \
  '{
    tag_name: $tag_name,
    name: $name,
    body: $body
  }')

# Make API request to create the release
echo "Creating release..."
RESPONSE=$(curl -s -X POST "https://codeberg.org/api/v1/repos/glossia/glossia/releases" \
  -H "Authorization: token $GLOSSIA_CODEBERG_WORKFLOWS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if echo "$RESPONSE" | grep -q '"id":'; then
    echo "Release created successfully!"
else
    echo "Failed to create release. Response:"
    echo "$RESPONSE"
fi

# Push image
echo "Pushing image..."
$container_cmd push $image_tag --creds pepicrft:$GLOSSIA_CODEBERG_WORKFLOWS_TOKEN

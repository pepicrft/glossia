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
export VERSION=$next_version

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
image_tag="ghcr.io/glossia/glossia:$next_version"
$container_cmd build --build-arg VERSION=$VERSION -t $image_tag .

# Updating the CHANGELOG.md
echo "Updating CHANGELOG.md..."
git cliff --bump -o CHANGELOG.md

echo "Updating version in mix.exs..."
sed -i '' 's/@version "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"/@version "$next_version"/' mix.exs

echo "Committing and tagging..."
git add CHANGELOG.md
git add mix.exs
git commit -m "[Release] Glossia $next_version"
git tag "$next_version"
# Push both the branch and tags
git push origin main  # or replace 'main' with your branch name
git push origin "$next_version"  # push the tag explicitly

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
    body: $body,
    draft: false,
    prerelease: false
  }')

# Make API request to create the release with correct GitHub API endpoint
echo "Creating release..."
RESPONSE=$(curl -s -X POST "https://api.github.com/repos/glossia/glossia/releases" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if echo "$RESPONSE" | grep -q '"id":'; then
    echo "Release created successfully!"
else
    echo "Failed to create release. Response:"
    echo "$RESPONSE"
fi

# Push image to the registry
echo "Pushing image..."
$container_cmd push $image_tag --creds pepicrft:$GITHUB_TOKEN

# Push a new version to the Hex package registry
# It authenticates using the env. variable HEX_API_KEY
echo "Pushing new version to Hex..."
mix hex.publish

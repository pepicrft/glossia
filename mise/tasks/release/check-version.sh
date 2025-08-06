#!/usr/bin/env bash
# mise description="Check if a new release is needed and determine version"

set -eo pipefail

# Get the latest tag
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "current_version=${CURRENT_VERSION}"

# Use git-cliff to determine if there are releasable changes
git-cliff --unreleased --strip header > UNRELEASED.md

# Check if there are any changes worth releasing
if [ -s UNRELEASED.md ]; then
  # Analyze commits to determine version bump
  # Check for breaking changes
  if git log ${CURRENT_VERSION}..HEAD --grep="BREAKING CHANGE" --grep="!:" | grep -q .; then
    BUMP_TYPE="major"
  # Check for features
  elif git log ${CURRENT_VERSION}..HEAD --grep="^feat" --grep="^feature" | grep -q .; then
    BUMP_TYPE="minor"
  # Check for fixes
  elif git log ${CURRENT_VERSION}..HEAD --grep="^fix" --grep="^bugfix" | grep -q .; then
    BUMP_TYPE="patch"
  else
    BUMP_TYPE="none"
  fi
  
  if [ "$BUMP_TYPE" != "none" ]; then
    # Parse current version
    VERSION=${CURRENT_VERSION#v}
    MAJOR=$(echo $VERSION | cut -d. -f1)
    MINOR=$(echo $VERSION | cut -d. -f2)
    PATCH=$(echo $VERSION | cut -d. -f3)
    
    # Calculate next version
    case $BUMP_TYPE in
      major)
        NEXT_VERSION="v$((MAJOR + 1)).0.0"
        ;;
      minor)
        NEXT_VERSION="v${MAJOR}.$((MINOR + 1)).0"
        ;;
      patch)
        NEXT_VERSION="v${MAJOR}.${MINOR}.$((PATCH + 1))"
        ;;
    esac
    
    echo "next_version=${NEXT_VERSION}"
    echo "bump_type=${BUMP_TYPE}"
    echo "should_release=true"
  else
    echo "No conventional commits found that warrant a release"
    echo "should_release=false"
  fi
else
  echo "No unreleased changes found"
  echo "should_release=false"
fi

# Clean up
rm -f UNRELEASED.md
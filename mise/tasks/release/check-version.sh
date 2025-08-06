#!/usr/bin/env bash
# mise description="Check if a new release is needed and determine version"

set -eo pipefail

# Get the latest tag (empty when none exist)
CURRENT_VERSION=$(git tag --list --sort=-v:refname | head -n1)
if [ -z "$CURRENT_VERSION" ]; then
  CURRENT_VERSION=""
  echo "current_version=v0.0.0"
else
  echo "current_version=${CURRENT_VERSION}"
fi

# Use git-cliff to determine if there are releasable changes
git-cliff --unreleased --strip header > UNRELEASED.md

# Check if there are any changes worth releasing
if [ -s UNRELEASED.md ]; then
  # Analyze commits to determine version bump
  # Use different range based on whether tags exist
  if [ -z "$CURRENT_VERSION" ]; then
    GIT_RANGE="HEAD"
  else
    GIT_RANGE="${CURRENT_VERSION}..HEAD"
  fi
  
  # Check for breaking changes
  if git log ${GIT_RANGE} --grep="BREAKING CHANGE" --grep="!:" | grep -q .; then
    BUMP_TYPE="major"
  # Check for features
  elif git log ${GIT_RANGE} --grep="^feat" --grep="^feature" | grep -q .; then
    BUMP_TYPE="minor"
  # Check for fixes
  elif git log ${GIT_RANGE} --grep="^fix" --grep="^bugfix" | grep -q .; then
    BUMP_TYPE="patch"
  else
    BUMP_TYPE="none"
  fi
  
  if [ "$BUMP_TYPE" != "none" ]; then
    # Parse current version (use 0.0.0 if no tags)
    if [ -z "$CURRENT_VERSION" ]; then
      VERSION="0.0.0"
    else
      VERSION=${CURRENT_VERSION#v}
    fi
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
#!/usr/bin/env bash
set -e

BUMP_TYPE=$1

CURRENT_VERSION=$(grep 'version:' mix.exs | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$CURRENT_VERSION" ]; then
  echo "Error: Could not find version in mix.exs"
  exit 1
fi

echo "Current version: $CURRENT_VERSION"

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $BUMP_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "New version: $NEW_VERSION"

if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/version: \"[^\"]*\"/version: \"$NEW_VERSION\"/" mix.exs
else
  # Linux
  sed -i "s/version: \"[^\"]*\"/version: \"$NEW_VERSION\"/" mix.exs
fi 

echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT 

#!/usr/bin/env bash

# Usage: ./bump_git_version.sh <major|minor|patch> - Increments the relevant version part by one.

set -e

function usage() {
    echo >&2 "Usage: $0 <major|minor|patch> - Increments the relevant version part by one."
}

if [[ ! "$1" == "major" ]] && [[ ! "$1" == "minor" ]] && [[ ! "$1" == "patch" ]]; then
	usage
	exit 1
fi;

current_version=$(git describe --abbrev=0 --tags)

IFS='.' read -a version_parts <<< "$current_version"

major=${version_parts[0]}
minor=${version_parts[1]}
patch=${version_parts[2]}

case "$1" in
    "major")
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    "minor")
        minor=$((minor + 1))
        patch=0
        ;;
    "patch")
        patch=$((patch + 1))
        ;;
esac

new_version="$major.$minor.$patch"

if ! [[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo >&2 "'to' version doesn't look like a valid semver version tag (e.g: 1.2.3). Aborting."
	exit 1
fi

echo $new_version;

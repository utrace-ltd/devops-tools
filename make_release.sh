#!/usr/bin/env bash

# Usage: ./make_release.sh <repository> - Add repository if need external use.

set -e

REPOSITORY=$1

function usage() {
    echo >&2 "Usage: $0 <repository> - Add repository if need external use."
}

if [ -z "${REPOSITORY}" ]; then
    usage
    exit 1
fi;

rm -fr ./_release && git clone ${REPOSITORY} ./_release > /dev/null 2>&1 && cd ./_release
git checkout master
git merge dev
version=$(bump_git_version.sh minor)
git tag $version
git push origin master $version
git checkout dev
git merge master
git push origin dev

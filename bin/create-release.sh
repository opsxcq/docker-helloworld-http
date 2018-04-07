#!/bin/bash

source $PWD/bin/helpers.sh

last_git_release=$(git describe --tags --abbrev=0)

new_version=$(processNewVersion)

TAG_EXISTS=0; git rev-parse --verify "v"$new_version || TAG_EXISTS=$? && true

if [ "$TAG_EXISTS" = "$0" ]
then
    git tag $new_version
    git config user.email "codefresh@codefresh.io"
    git config user.name "Automation"
    git push --tags
fi

cf_export LAST_GIT_VERSION=$last_git_release
#!/bin/bash

source $PWD/bin/helpers.sh

kubectl config use-context $WORKING_CLUSTER
version_in_cluster=$(kubectl get pod -l app=$(processReleaseName)  -o custom-columns=VERSION:.metadata.labels.version | tail -n 1)

if [ "$LAST_GIT_VERSION" != "$version_in_cluster" ]
then
    echo "Last version in git not match to current version in production."
    exit -1
fi
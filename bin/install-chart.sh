#!/bin/bash

runCodefreshCmd(){
    cmd = "codefresh install-chart"
    cmd = "$cmd --cluster $WORKING_CLUSTER"
    cmd = "$cmd --namespace $NAMESPACE"
    cmd = "$cmd --repository $HELM_REPO_NAME"
    cmd = "$cmd -b $CF_BRANCH_TAG_NORMALIZED"

    echo "Running install cmd: $cmd"
    eval cmd
}

runCodefreshCmd
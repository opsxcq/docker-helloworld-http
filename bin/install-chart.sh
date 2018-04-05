#!/bin/bash

runCodefreshCmd(){
    cmd="codefresh install-chart"
    cmd="$cmd --cluster $WORKING_CLUSTER"
    cmd="$cmd --namespace $NAMESPACE"
    cmd="$cmd --repository $HELM_REPO_NAME"
    cmd="$cmd --name $CHART_NAME"
    cmd="$cmd --version $CHART_VERSION"

    echo "Running install cmd: $cmd"
    eval $cmd
}

runCodefreshCmd
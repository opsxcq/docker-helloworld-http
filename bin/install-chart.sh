#!/bin/bash

runCodefreshCmd(){
    cmd="codefresh install-chart"
    cmd="$cmd --tiller-namespace kube-system"
    cmd="$cmd --cluster $WORKING_CLUSTER"
    cmd="$cmd --namespace $NAMESPACE"
    cmd="$cmd --repository $HELM_REPO_NAME"
    cmd="$cmd --name $CHART_NAME"
    cmd="$cmd --version $VERSION"

    echo "Running install cmd: $cmd"
    eval $cmd
}

runCodefreshCmd
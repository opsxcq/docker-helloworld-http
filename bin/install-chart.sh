#!/bin/bash

runCodefreshCmd(){
    cmd = "codefresh install-chart"
    cmd = "$cmd --cluster $WORKING_CLUSTER"
    cmd = "$cmd --namespace $NAMESPACE"
    cmd = "$cmd --repository $HELM_REPO_NAME"
    
    echo "Running install cmd: $cmd"
    eval cmd
}

runCodefreshCmd
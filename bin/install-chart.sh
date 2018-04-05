#!/bin/bash

runCodefreshCmd(){
    cmd="codefresh install-chart"
    cmd="$cmd --tiller-namespace kube-system"
    cmd="$cmd --cluster $WORKING_CLUSTER"
    cmd="$cmd --namespace $NAMESPACE"
    cmd="$cmd --repository $HELM_REPO_NAME"
    cmd="$cmd --name $CHART_NAME"
    cmd="$cmd --release-name $CF_BRANCH_TAG_NORMALIZED"
    cmd="$cmd --version $VERSION"
    # if $IS_FEATURE ; then cmd="$cmd --set redeploy=true" ; fi

    echo "Running install cmd: $cmd"
    eval $cmd
}

runCodefreshCmd
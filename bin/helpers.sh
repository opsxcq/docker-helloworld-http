#!/bin/bash

exportVariables(){
    #check if master
    cf_export CHART_NAME=$1 #chart name
    cf_export VERSION=$2 # version
    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        cf_export NAMESPACE="default"
        cf_export HELM_REPO_NAME="Stable"
        cf_export IS_FEATURE=false
    else
        cf_export NAMESPACE=$CF_BRANCH_TAG_NORMALIZED
        cf_export HELM_REPO_NAME="Dev"
        cf_export IS_FEATURE=true
    fi
}

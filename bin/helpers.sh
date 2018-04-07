#!/bin/bash

defaultBranch="master"

exportVariables(){
    #check if master
    cf_export CHART_NAME=$1 #chart name
    cf_export VERSION=$2 # version
    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        cf_export NAMESPACE="default"
        cf_export HELM_REPO_NAME="stable"
        cf_export IS_FEATURE=false
    else
        cf_export NAMESPACE=$CF_BRANCH_TAG_NORMALIZED
        cf_export HELM_REPO_NAME="dev"
        cf_export IS_FEATURE=true
    fi
}

processNewVersion(){
    # chart version based on version from VERSION file and current branch tag
    local current_version=$(cat $repo_dir/VERSION)

    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        echo $current_version
    else
        echo $current_version-$CF_BRANCH_TAG_NORMALIZED
    fi
}

fetchHelmRepoURL(){
    # Codefresh sets the URL to the repo as CF_CTX_(name of the repo)_URL=....
    local namePrefix=""
    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        namePrefix="stable"
    else
        namePrefix="dev"
    fi
    echo $(env | grep CF_CTX_$namePrefix | sed s/CF_CTX_.*=//g)
}

fetchPushRepoPath(){
    local name=""
    local basicPath=$(echo $(fetchHelmRepoURL) | sed s/codefresh/api\\/codefresh/g)
    echo $basicPath'charts'
}

fetchChartName(){
    echo $(echo $PWD | sed 's:'$CF_VOLUME_PATH\/'::g')
}

processReleaseName(){
    echo $CF_BRANCH_TAG_NORMALIZED
}
#!/bin/bash

# repository path in codefresh volume
repo_dir=$CF_VOLUME_PATH/docker-helloworld-http

# chart directory
chart_name="docker-helloworld-http"
chart_dir=$repo_dir/$chart_name

# chart version based on version from VERSION file and current branch tag
current_version=$(cat $repo_dir/VERSION)
new_version=$(echo $current_version-$CF_BRANCH_TAG_NORMALIZED)

# Codefresh gives the URL to the repo as CF_CTX_(name of the repo)_URL=....
helmRepoUrl=$(env | grep CF_CTX | sed s/CF_CTX_.*=//g)

updateValuesWithCurrentImageTag(){
    yq '.imageTag = env.CF_BRANCH_TAG_NORMALIZED' $chart_dir/values.yaml --yaml-output > $CF_VOLUME_PATH/values.new.yaml
    mv $CF_VOLUME_PATH/values.new.yaml $chart_dir/values.yaml
}

updateChartSourceWithCommitUrl(){
    yq  '.sources[.sources | length] = env.CF_COMMIT_URL' $chart_dir/Chart.yaml --yaml-output > $CF_VOLUME_PATH/Chart.new.yaml
    mv $CF_VOLUME_PATH/Chart.new.yaml $chart_dir/Chart.yaml
}

packageChart(){
    echo="$(helm package $chart_dir --version $new_version --destination $CF_VOLUME_PATH | cut -d " " -f 8 )"
}

pushPackgeToHelmRepo(){
    helmRepoUrl=$(env | grep CF_CTX | sed s/CF_CTX_.*=//g)
    packagePath=$CF_VOLUME_PATH/$chart_name-$new_version.tgz
    curl --user $HELMREPO_USERNAME:$HELMREPO_PASSWORD --fail --data-binary "@$packagePath" $helmRepoUrl/api/charts
}

exportVariables(){
    #check if master
    defaultBranch="master"
    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        cf_export VERSION=$current_version
        cf_export NAMESPACE=$CF_BRANCH_TAG_NORMALIZED
        cf_export HELM_REPO_NAME="Stable"
    else
        cf_export VERSION=$new_version
        cf_export NAMESPACE="default"
        cf_export HELM_REPO_NAME="Dev"
    fi
}


echo "Setting new image tag to be: $CF_BRANCH_TAG_NORMALIZED\n"
$(updateValuesWithCurrentImageTag)

echo "Adding metadata to chart source\nCommit URL: $CF_COMMIT_URL\n"
$(updateChartSourceWithCommitUrl)

echo "Packaging chart with new version $new_version to $CF_VOLUME_PATH path\n"
echo $(packageChart)

echo "Pushing package to Helm repo: $helmRepoUrl\n"
pushPackgeToHelmRepo

echo "exporting variables to next steps\m"
exportVariables

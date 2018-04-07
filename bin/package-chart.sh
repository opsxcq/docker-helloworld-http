#!/bin/bash

echo "PWD: $PWD"
ls $PWD
ls $PWD/bin

source $PWD/bin/helpers.sh

# this is the default branch 
defaultBranch="master"

processNewVersion(){
    if [ "$CF_BRANCH_TAG_NORMALIZED" = "$defaultBranch" ]
    then
        echo $current_version
    else
        echo $current_version-$CF_BRANCH_TAG_NORMALIZED
    fi
}

# repository path in codefresh volume
repo_dir=$CF_VOLUME_PATH/docker-helloworld-http

# chart directory
chart_name="docker-helloworld-http"
chart_dir=$repo_dir/$chart_name

# chart version based on version from VERSION file and current branch tag
current_version=$(cat $repo_dir/VERSION)
new_version=$(processNewVersion)

# Codefresh gives the URL to the repo as CF_CTX_(name of the repo)_URL=....
helmRepoUrl=$(env | grep CF_CTX | sed s/CF_CTX_.*=//g)


updateValuesWithCurrentImageTag(){
    cmd='yq'
    # Add argument to be used inside jq
    cmd="$cmd --arg new_version \"$new_version\""
    # set imageTag to the version
    cmd="$cmd '.imageTag = \$new_version'"
    # save in new file
    cmd="$cmd $chart_dir/values.yaml --yaml-output > $CF_VOLUME_PATH/values.new.yaml"
    eval $cmd
    # replace the value file 
    mv $CF_VOLUME_PATH/values.new.yaml $chart_dir/values.yaml
}

updateChartSourceWithCommitUrl(){
    cmd='yq'
    # Add to source the commit ur
    cmd="$cmd '.sources[.sources | length] |= . + env.CF_COMMIT_URL'"
    # save in new file
    cmd="$cmd $chart_dir/Chart.yaml --yaml-output > $CF_VOLUME_PATH/Chart.new.yaml"
    eval $cmd
    # replace the Chart file 
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


echo "Setting new image tag to be: $CF_BRANCH_TAG_NORMALIZED"
$(updateValuesWithCurrentImageTag)

echo "Adding metadata to chart source"
echo "Commit URL: $CF_COMMIT_URL\n"
$(updateChartSourceWithCommitUrl)

echo "Packaging chart with new version $new_version to $CF_VOLUME_PATH path"
echo $(packageChart)

echo "Pushing package to Helm repo: $helmRepoUrl"
pushPackgeToHelmRepo

echo
echo "exporting variables to next steps"
exportVariables

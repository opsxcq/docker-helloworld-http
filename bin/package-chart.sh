#!/bin/bash

source $PWD/bin/helpers.sh

name=$(echo $PWD | sed 's:'$CF_VOLUME_PATH\/'::g')

# repository path in codefresh volume
repo_dir=$CF_VOLUME_PATH/$name

# chart directory
chart_name=$name
chart_dir=$repo_dir/$chart_name

new_version=$(processNewVersion)

helmRepoUrl=$(fetchHelmRepoURL)


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
    local packagePath=$CF_VOLUME_PATH/$chart_name-$new_version.tgz
    local URL=$(fetchPushRepoPath)
    curl --fail --data-binary "@$packagePath" $URL
}


echo "Setting new image tag to be: $CF_BRANCH_TAG_NORMALIZED"
$(updateValuesWithCurrentImageTag)

echo "Adding metadata to chart source"
echo "Commit URL: $CF_COMMIT_URL"
$(updateChartSourceWithCommitUrl)

echo "Packaging chart with new version $new_version to $CF_VOLUME_PATH path"
echo $(packageChart)

echo "Pushing package to Helm repo: $(fetchPushRepoPath)"
pushPackgeToHelmRepo

echo
echo "exporting variables to next steps"
exportVariables $chart_name $new_version

#!/bin/bash

# repository path in codefresh volume
repo_dir=$CF_VOLUME_PATH/docker-helloworld-http

# chart director
chart_dir=$repo_dir/docker-helloworld-http

# chart version based on version from VERSION file and current branch tag
chart_version=$(echo $(cat $repo_dir/VERSION)-$CF_BRANCH_TAG_NORMALIZED)

updateValuesWithCurrentImageTag(){
    yq '.imageTag = env.CF_BRANCH_TAG_NORMALIZED' $chart_dir/values.yaml --yaml-output > $CF_VOLUME_PATH/values.new.yaml
    mv $CF_VOLUME_PATH/values.new.yaml $chart_dir/values.yaml
}

updateChartSourceWithCommitUrl(){
    yq  '.sources[.sources | length] = env.CF_COMMIT_URL' $chart_dir/Chart.yaml --yaml-output > $CF_VOLUME_PATH/Chart.new.yaml
    mv $CF_VOLUME_PATH/Chart.new.yaml $chart_dir/Chart.yaml
}

packageChart(){
    echo="$(helm package $chart_dir --version $chart_version --destination $CF_VOLUME_PATH | cut -d " " -f 8 )"
}


echo "Setting new image tag to be: $CF_BRANCH_TAG_NORMALIZED"
$(updateValuesWithCurrentImageTag)

echo "Adding metadata to chart source\nCommit URL: $CF_COMMIT_URL"
$(updateChartSourceWithCommitUrl)

echo "Packaging chart with new version $chart_version to $CF_VOLUME_PATH path"
echo $(packageChart)
echo "Package full path is $package_path"
ls $CF_VOLUME_PATH


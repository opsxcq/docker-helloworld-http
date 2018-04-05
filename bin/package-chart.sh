#!/bin/bash

updateValuesWithCurrentImageTag(){
    yq '.imageTag = env.CF_BRANCH_TAG_NORMALIZED' $chart_dir/values.yaml --yaml-output > $CF_VOLUME_PATH/values.new.yaml
    mv $CF_VOLUME_PATH/values.new.yaml $chart_dir/values.yaml
}

updateChartSourceWithCommitUrl(){
     yq  '.sources[.sources | length] = env.CF_COMMIT_URL' $chart_dir/Chart.yaml --yaml-output > $CF_VOLUME_PATH/Chart.new.yaml
     mv $CF_VOLUME_PATH/Chart.new.yaml $chart_dir/Chart.yaml
}

packageChart(){
    chrt_path=$(helm package $chart_dir --version $CHRAT_FULL_SEMVER --destination $CF_VOLUME_PATH | cut -d " " -f 8 )
}

# repository path in codefresh volume
repo_dir=$CF_VOLUME_PATH/docker-helloworld-http

# chart director
chart_dir=$repo_dir/docker-helloworld-http

# chart version based on version from VERSION file and current branch tag
chart_version=$(echo $(cat $repo_dir/VERSION)-$CF_BRANCH_TAG_NORMALIZED)
echo $chart_version

$(updateValuesWithCurrentImageTag)
cat $chart_dir/values.yaml

$(updateChartSourceWithCommitUrl)
cat $chart_dir/Chart.yaml

$(packageChart)


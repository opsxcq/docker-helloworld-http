#!/bin/bash

# update imageTag in values.yaml

repo_dir=$CF_VOLUME_PATH/docker-helloworld-http
chart_dir=$repo_dir/docker-helloworld-http
cat $chart_dir/values.yaml

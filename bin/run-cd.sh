#!/bin/bash

codefresh run $CD_PIPELINE_NAME \
    -d \
    -b $CF_BRANCH_TAG_NORMALIZED \
    --variable VERSION=$VERSION \
    --variable NAMESPACE=$NAMESPACE \
    --variable HELM_REPO_NAME=$HELM_REPO_NAME \
    --variable CHART_NAME=$CHART_NAME \
    --variable IS_FEATURE=$IS_FEATURE
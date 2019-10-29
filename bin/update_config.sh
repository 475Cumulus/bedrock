#!/bin/bash
set -ex
# required env vars: CLUSTER_NAME, CONFIG_BRANCH, CONFIG_REPO, NAMESPACE,
# DEPLOYMENT_YAML, DEPLOYMENT_LOG_BASE_URL, DEPLOYMENT_NAME, DEPLOYMENT_VERSION

. ${BASH_SOURCE%/*}/../docker/bin/set_git_env_vars.sh # sets DEPLOYMENT_DOCKER_IMAGE
pushd $(mktemp -d)
git clone --depth=1 -b ${CONFIG_BRANCH:=master} ${CONFIG_REPO} config_checkout
cd config_checkout

set -u
for CLUSTER in ${CLUSTERS:=iowa-a}; do
    for DEPLOYMENT in {clock-,}deploy.yaml $DEPLOYMENT_YAML; do
        DEPLOYMENT_FILE=${CLUSTER}/${NAMESPACE:=bedrock-dev}/${DEPLOYMENT}
        if [[ -f ${DEPLOYMENT_FILE} ]]; then
            sed -i -e "s|image: .*|image: ${DOCKER_IMAGE_TAG}|" ${DEPLOYMENT_FILE}
            git add ${DEPLOYMENT_FILE}
        fi
    done
done
git commit -m "set image to ${DEPLOYMENT_DOCKER_IMAGE} in ${CLUSTERS}" || echo "nothing new to commit"
git push
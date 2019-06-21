#!/bin/bash

set -e

if [[ ! "$DEVOPS_PRIVATE_KEY_BASE64" == "" ]]; then
	echo $DEVOPS_PRIVATE_KEY_BASE64 | base64 -d > /root/.ssh/id_rsa
	chmod 600 /root/.ssh/id_rsa
fi;

if [[ ! "${YC_PROFILES_BASE64}" == "" ]]; then
	echo ${YC_PROFILES_BASE64}== | base64 -d > /root/.config/yandex-cloud/config.yaml
	chmod 600 /root/.config/yandex-cloud/config.yaml
fi;

if [[ ! "${KUBECTL_CONFIG_BASE64}" == "" ]]; then
	echo ${KUBECTL_CONFIG_BASE64}== | base64 -d > /root/.kube/config
	chmod 600 /root/.kube/config
fi;

git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"

echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> /root/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> /root/.aws/credentials

echo "[default]" > /root/.aws/config
echo "region = $AWS_REGION" >> /root/.aws/config

exec "$@"

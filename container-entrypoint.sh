#!/bin/bash

set -e

if [[ ! "$DEVOPS_PRIVATE_KEY_BASE64" == "" ]]; then
	echo $DEVOPS_PRIVATE_KEY_BASE64== | base64 -d > /home/devops/.ssh/id_rsa
	chmod 600 /home/devops/.ssh/id_rsa
fi;

if [[ ! "${KUBECTL_CONFIG_BASE64}" == "" ]]; then
	echo ${KUBECTL_CONFIG_BASE64}== | base64 -d > /home/devops/.kube/config
	chmod 600 /home/devops/.kube/config
fi;

if [[ ! "${KUBECTL_VAULT_AUTO_CONFIG}" == "" ]]; then
	kubectl_vault_auto_config.sh ${KUBECTL_VAULT_AUTO_CONFIG}
fi;

git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"

echo "[default]" > /home/devops/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> /home/devops/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> /home/devops/.aws/credentials

echo "[default]" > /home/devops/.aws/config
echo "region = $AWS_REGION" >> /home/devops/.aws/config

exec "$@"

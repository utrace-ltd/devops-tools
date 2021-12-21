#!/usr/bin/env bash

set -e

VAULT_PATH=$1

if [[ -z "$VAULT_PATH" ]]; then
  echo "Usage $0 [vault path] - configure kubectl from vault secrets"
  exit 1
fi;

vault kv get -format=json $VAULT_PATH > /tmp/config.json
if [[ $? -ne 0 ]]; then
  echo "Error on get value from vault"
  exit 1
fi;

CERTIFICATE_AUTHORITY_DATA=$(jq -r '.data.data."certificate-authority-data"' /tmp/config.json)
SERVER=$(jq -r '.data.data.server' /tmp/config.json)
TOKEN=$(jq -r '.data.data.token' /tmp/config.json)

rm -f /tmp/config.json

if [[ "$CERTIFICATE_AUTHORITY_DATA" == "null" || "$SERVER" == "null" || "$TOKEN" == "null" ]]; then
  echo "Error on get k8s cluster settings from vault, certificate-authority-data or server or token not found"
  exit 1
fi;

kubectl config set-cluster k8s_server --server=$SERVER > /dev/null
kubectl config set clusters.k8s_server.certificate-authority-data $CERTIFICATE_AUTHORITY_DATA > /dev/null
kubectl config set-credentials k8s_user --token="$TOKEN" > /dev/null
kubectl config set-context k8s_context --cluster=k8s_server --user=k8s_user > /dev/null
kubectl config use-context k8s_context > /dev/null

#!/bin/sh
echo "### Validating... ###"
echo 'env NEW_CLI=1 $(cat ./demo.env) ./monaco-1.8.9 deploy -d -v -e existing_v1_config/environments.yaml existing_v1_config'
env NEW_CLI=1 $(cat ./demo.env) ./monaco-1.8.9 deploy -d -v -e existing_v1_config/environments.yaml existing_v1_config

echo "### Deploying... ###"
echo 'env NEW_CLI=1 $(cat ./demo.env) ./monaco-1.8.9 deploy -v -e existing_v1_config/environments.yaml existing_v1_config'
env NEW_CLI=1 $(cat ./demo.env) ./monaco-1.8.9 deploy -v -e existing_v1_config/environments.yaml existing_v1_config
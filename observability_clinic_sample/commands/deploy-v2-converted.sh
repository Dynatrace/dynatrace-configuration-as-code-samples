#!/bin/sh
echo "### Validating... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 deploy -v converted_v2_config/manifest.yaml -d'
env $(cat ./demo.env) ./monaco-2.0.0 deploy -v converted_v2_config/manifest.yaml -d

echo "### Deploying... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 deploy -v converted_v2_config/manifest.yaml'
env $(cat ./demo.env) ./monaco-2.0.0 deploy -v converted_v2_config/manifest.yaml 

#!/bin/sh
echo "### Validating... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 deploy -v settings-demo/manifest.yaml -d'
env $(cat ./demo.env) ./monaco-2.0.0 deploy -v settings-demo/manifest.yaml -d

echo "### Deploying... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 deploy -v settings-demo/manifest.yaml'
env $(cat ./demo.env) ./monaco-2.0.0 deploy -v settings-demo/manifest.yaml 

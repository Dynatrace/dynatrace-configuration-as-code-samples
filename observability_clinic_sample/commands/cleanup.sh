#!/bin/sh
echo "### Removing test configs from environment... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 delete --manifest settings-demo/manifest.yaml'
env $(cat ./demo.env) ./monaco-2.0.0 delete --manifest settings-demo/manifest.yaml

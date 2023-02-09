#!/bin/sh
echo "### Removing test configs from environment... ###"
echo 'env $(cat ./demo.env) ./monaco-2.0.0 delete settings-demo/manifest.yaml delete.yaml'
env $(cat ./demo.env) ./monaco-2.0.0 delete settings-demo/manifest.yaml delete.yaml 

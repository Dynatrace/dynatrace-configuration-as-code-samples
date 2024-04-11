#!/bin/sh
sed -i .bak "s/%YOUR_ENVIRONMENT_ID%/$YOUR_ENVIRONMENT_ID/g" ./casc-admin/groups.yaml
sed -i .bak "s/%YOUR_USER_EMAIL%/$YOUR_USER_EMAIL/g" ./casc-admin/users.yaml
sed -i .bak "s/%YOUR_USER_EMAIL%/$YOUR_USER_EMAIL/g" ./delete.yaml

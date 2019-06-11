#!/usr/bin/env bash

cd ~

git clone https://github.com/tmarkunin/infra.git
cd infra
bash install_ruby.sh
bash install_mongo.sh
bash deploy_app.sh

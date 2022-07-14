#!/bin/bash

# check if gh binary is available
if [ -x "$(command -v gh)" ]; then
    echo 'gh cli is installed.'
    exit 0
fi

version=${GH_CLI_VERSION:-2.8.0}
echo "Installing gh cli in version: $version"

wget https://github.com/cli/cli/releases/download/v${version}/gh_${version}_linux_amd64.tar.gz
tar -xvf gh_${version}_linux_amd64.tar.gz
sudo cp $(pwd)/gh_${version}_linux_amd64/bin/gh /usr/local/bin/
#!/bin/bash

# check if gh binary is available
if [ -x "$(command -v gh)" ]; then
    echo 'gh cli is installed.'
    exit 0
fi

version=${GH_CLI_VERSION:-2.8.0}
echo "Installing gh cli in version: $version"

machine=$(uname -m)
case $machine in
    aarch64)
        arch="arm64"
        ;;
    x86_64)
        arch="amd64"
        ;;
    *)
        echo "Unsupported architecture: $machine"
        exit 1
        ;;
esac

wget https://github.com/cli/cli/releases/download/v${version}/gh_${version}_linux_${arch}.tar.gz
tar -xvf gh_${version}_linux_${arch}.tar.gz
sudo cp $(pwd)/gh_${version}_linux_${arch}/bin/gh /usr/local/bin/
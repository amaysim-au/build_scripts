#!/bin/bash -e

wget --quiet https://github.com/rancher/cli/releases/download/v0.2.0/rancher-linux-amd64-v0.2.0.tar.gz -O | tar xz
sudo mv ./rancher-v0.2.0/rancher /usr/local/bin/rancher
rancher -version
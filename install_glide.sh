#!/bin/bash -e

# install glide
echo "installing glide latest"
# sudo apt-get -y --no-install-recommends -qq install software-properties-common python-software-properties
# sudo add-apt-repository ppa:masterminds/glide && sudo apt-get -qq update
# sudo apt-get -y install golang glide
# go version && glide -version
curl https://glide.sh/get | sh
#!/bin/bash -e

GOVERSION=$1

# install go
echo "installing golang ${GOVERSION}"
cd /usr/local && wget --quiet https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz -O - | sudo tar -xz
mkdir $HOME/go
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
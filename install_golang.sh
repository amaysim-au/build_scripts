#!/bin/bash -e

GOVERSION=$1
WORKDIR=$PWD

# install go
echo "installing golang ${GOVERSION}"
cd /usr/local 
wget --quiet https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz -O - | sudo tar -xz
cd $WORKDIR

export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

if [ ! -d $GOPATH ]; then
	mkdir $GOPATH
fi

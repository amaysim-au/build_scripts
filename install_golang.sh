#!/bin/bash -e

GOVERSION=$1
WORKDIR=$PWD

# install go
echo "installing golang ${GOVERSION}"
cd /usr/local
if [ ! -d $GOPATH ]; then
	mkdir $GOPATH
fi

wget --quiet https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz -O - | sudo tar -xz
cd $WORKDIR

PATH=$PATH:$GOROOT/bin:$GOPATH/bin
go version

# install glide
curl https://glide.sh/get | sh
glide version
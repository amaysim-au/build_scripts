#!/usr/bin/env bash -e

function createGoPath() {
	local namespace=$1
	if [ ! -d ${GOPATH}/src ]; then
		mkdir -p ${GOPATH}/src
	fi
	if [ ! -d ${GOPATH}/bin ]; then
		mkdir -p ${GOPATH}/bin
	fi
	if [ ! -d ${GOPATH}/pkg ]; then
		mkdir -p ${GOPATH}/pkg
	fi
}

function installGolang() {
	local goversion=$1
	echo "installing golang ${goversion} into ${GOROOT}"
	wget --quiet https://storage.googleapis.com/golang/go${goversion}.linux-amd64.tar.gz -O - | tar -xz
	sudo mv go ${GOROOT}
	createGoPath
}

function symlinkRepo() {
	local namespace=$1
	echo "creating repo symlink in ${GOPATH}"
	createGoPath
	if [ ! -d $GOPATH/src/${namespace} ]; then
		mkdir -p $GOPATH/src/${namespace}
	fi
	ln -s $PWD $GOPATH/src/$namespace
}

function installGlide() {
	echo "installing glide latest"
	curl -s https://glide.sh/get | sh
}

if [ "$#" -ne 2 ]; then
    echo "Usage: install_golang.sh {goversion} {namespace}"
    exit 1
fi

installGolang $1
symlinkRepo $2
PATH=$PATH:$GOROOT/bin:$GOPATH/bin

installGlide

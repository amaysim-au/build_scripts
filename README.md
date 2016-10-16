# build_scripts

Common build scripts for bootstrapping snapCI Stages.

## Installation

	wget https://github.com/amaysim-au/build_scripts/archive/master.zip -O build-scripts.zip && 
		unzip -o build-scripts.zip && 
		sudo mv build_scripts-master/* /usr/local/bin

## Usage

	#Deploys a container to rancher
    deploy.sh 

    #Check if an application is Up
    check_if_app_is_UP.sh

    #installs golang and glide, and creates a symblink in GOPATH
    source install_golang.sh {goversion} {namespace} 

    #installs rancher CLI
    install_rancher_cli.sh
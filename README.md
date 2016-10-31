# build_scripts

Common build scripts for bootstrapping snapCI Stages.

## Installation

	wget https://github.com/amaysim-au/build_scripts/archive/master.zip -O build-scripts.zip && 
		unzip -o build-scripts.zip && 
		sudo mv build_scripts-master/* /usr/local/bin

## Usage

    #installs rancher CLI
    install_rancher_cli.sh

	#Deploys a container to rancher
    deploy.sh 

    #Check if an application is Up
    check_if_app_is_UP.sh

    #installs golang and glide, and creates a symblink in GOPATH
    source install_golang.sh {goversion} {namespace} {repo}
    source install_golang.sh "1.7.1" "github.com/amaysim-au" "awesome-app"

    #install postgres
    install_postgres.sh {VERSION} {USERNAME} {PASSWORD} {DATABASE_NAME}
    install_postgres.sh "9.5" "test_user" "pa55w0rd" "awesome_app_test"

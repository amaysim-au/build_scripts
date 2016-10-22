#!/bin/bash -e

usage="$(basename "$0") [-h] [-e ENVIRONMENT] [-s STACK] [-c SERVICE] [-r RANCHER_COMMAND] [-d DOCKER_COMPOSE_FILE] [-n RANCHER_COMPOSE_FILE] [-w WAIT_TIME_SECS] -- script to upgrade and deploy containers in the given environment.
Make sure that you have rancher environment options set and rancher cli installed before running the script.

where:
-h  show this help text
-e  set the rancher environment (default: Dev)
-s  set the rancher stack (default: QA)
-c  set the rancher service (default: poseidon-app)
-r  set the rancher command (default: ./rancher)
-d  set the docker-compose file (default: deployment/docker-compose.yml)
-n  set the rancher-compose file (default: deployment/rancher-compose.yml)
-w  set the wait time in seconds (default: 120)"

env=Dev
stack=QA
service=poseidon-app
rancher_command=rancher
docker_compose_file=deployment/docker-compose.yml
rancher_compose_file=deployment/rancher-compose.yml
WAIT_TIMEOUT=120
NUMBER_OF_TIMES_TO_LOOP=$(( $WAIT_TIMEOUT/10 ))

while getopts ':e:s:c:r:w:d:n:h' option; do
    case "$option" in
        h)  echo "$usage"
            exit
            ;;
        e)  env=$OPTARG
            ;;
        s)  stack=$OPTARG
            ;;
        c)  service=$OPTARG
            ;;
        r)  rancher_command=$OPTARG
            ;;
        d)  docker_compose_file=$OPTARG
            ;;
        n)  rancher_compose_file=$OPTARG
            ;;
        w)  WAIT_TIMEOUT=$OPTARG
            NUMBER_OF_TIMES_TO_LOOP=$(( $WAIT_TIMEOUT/10 ))
            ;;
        :)  printf "missing argument for -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

function upgrade_the_service(){
    echo  "Upgrading $service in $env"
    $rancher_command --environment $env --debug --wait --wait-timeout $WAIT_TIMEOUT up --batch-size 1 -s $stack -f $docker_compose_file --rancher-file $rancher_compose_file --upgrade -p -d
    monitor_transition
    state_after_upgrade=`$rancher_command --env $env inspect --format '{{ .state}}' $stack/$service | head -n1`
    echo  "The state of service after upgrade is $state_after_upgrade"
    case $state_after_upgrade in
        "active")  exit 0
                   ;;
        "upgraded") finish_upgrade
                   ;;
        *)  echo "Service isnt responding. Exiting."
            exit 1
            ;;
    esac
}

function finish_upgrade(){
    health_status=`$rancher_command --environment $env inspect --format '{{ .healthState}}' $stack/$service | head -n1`
    if [[ $health_status == "healthy" ]]
        then
            echo "Upgraded service successfully. Confirming Upgrade."
            $rancher_command --environment $env --debug --wait --wait-state active --wait-timeout $WAIT_TIMEOUT up -s $stack -f $docker_compose_file --rancher-file $rancher_compose_file --confirm-upgrade -d
            echo "Upgraded service successfully and confirmed."
            wait_for_service_to_have_status "healthy" ".healthState"
            exit 0
        else
            roll_back
    fi
}

function roll_back(){
    echo "Upgrade failed. Initiating rollback to the previous deployed version"
    $rancher_command --environment $env --debug --wait --wait-state active --wait-timeout $WAIT_TIMEOUT up --batch-size 1 -s $stack -f $docker_compose_file --rancher-file $rancher_compose_file --rollback -d
    wait_for_service_to_have_status "healthy" ".healthState"
    echo "Upgrade failed. Rolled back to the previous deployed version"
    exit 1
}

function exit_if_service_currently_unhealthy() {
    health_status=`$rancher_command --environment $env inspect --format '{{ .healthState}}' $stack/$service | head -n1`
    echo  "The current health status of service is $health_status"
    if [[ "$health_status" != "healthy" ]]
        then
        echo  "The Service is not in a healthy state. Exiting."
        exit 1
    fi
}

function confirm_upgrade_if_previous_upgrade_pending() {
    service_status=`$rancher_command --environment $env inspect --format '{{ .state}}' $stack/$service | head -n1`
    echo  "The status of previous service upgrade is $service_status"
    if [[ "$service_status" == "upgraded" ]]
    then
        echo "Previous Upgrade not completed. Confirming the previous Upgrade before continuing."
        $rancher_command --environment $env --debug --wait --wait-state active --wait-timeout $WAIT_TIMEOUT up -s $stack -f $docker_compose_file --rancher-file $rancher_compose_file --confirm-upgrade -d
        wait_for_service_to_have_status "healthy" ".healthState"
    fi
}

function wait_for_service_to_have_status() {
    status_type=$1
    status_tag=$2
    status=`$rancher_command --environment $env inspect --format '{{ '"$status_tag"' }}' $stack/$service | head -n1`
    echo "Waiting for service to be $status_type. Current status: $status"
    COUNT=0
    while [ $status != $status_type ]; do
        if [ $COUNT -gt $NUMBER_OF_TIMES_TO_LOOP ]; then
            echo "Error: Give up waiting for service status to be $status_type. Please investigate. Exiting."
            exit 1;
        fi
        COUNT=$[$COUNT + 1]
        echo "Waiting for service to be $status_type. Current status: $status"
        sleep 10
        status=`$rancher_command --environment $env inspect --format '{{ '"$status_tag"' }}' $stack/$service | head -n1`
    done
    echo "Service is now $status."
}

function monitor_transition() {
    is_transitioning=`$rancher_command --environment $env inspect --format '{{ .transitioning }}' $stack/$service | head -n1`
    echo "Is service transtioning state: $is_transitioning"
    COUNT=0
    while [ $is_transitioning != "no" ]; do
        if [ $COUNT -gt $NUMBER_OF_TIMES_TO_LOOP ]; then
            echo "Give up waiting for becoming steady, Starting rollback"
            roll_back
        fi
        COUNT=$[$COUNT + 1]
        echo "Waiting for transition status to be no. Previous status: $is_transitioning"
        sleep 10
        is_transitioning=`$rancher_command --environment $env inspect --format '{{ .transitioning }}' $stack/$service | head -n1`
        echo "Current status: $is_transitioning"
    done
    echo "Transitioning status is now $is_transitioning"
}

is_sevice_exists=`$rancher_command --environment $env inspect $stack/$service | head -n1`
if [[ $is_sevice_exists != *"Not found"* ]]
then
    exit_if_service_currently_unhealthy
    confirm_upgrade_if_previous_upgrade_pending
fi
upgrade_the_service

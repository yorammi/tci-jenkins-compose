#!/bin/bash

set -e

action='restart'
if [[ $# > 0 ]]; then
    action=$1
fi
if [[ "$action" == "upgrade" ]]; then
    git pull origin HEAD
fi


if [ ! -f tci.config ]; then
    cp templates/tci-server/tci.config.template tci.config
    action='init'
fi

mkdir -p customization/docker-compose
mkdir -p customization/files
mkdir -p customization/userContent
mkdir -p customization/tci-master

source templates/tci-server/tci.config.template
source tci.config

if [[ "$action" == "init" || "$action" == "upgrade" ]]; then
    echo "Initializing tci-server. You'll need to restart the server after that action."
    . ./scripts/init-tci.sh
fi

if [ ! -f customization/docker-compose/docker-compose.yml.template ]; then
    cp templates/docker-compose/docker-compose.yml.template customization/docker-compose/docker-compose.yml.template
fi
echo "# PLEASE NOTICE:" > docker-compose.yml
echo "# This is a generated file, so any change in it will be lost on the next TCI action!" >> docker-compose.yml
echo "" >> docker-compose.yml
cat customization/docker-compose/docker-compose.yml.template >> docker-compose.yml
numberOfFiles=`ls -1q customization/docker-compose/*.yml 2> /dev/null | wc -l | xargs`
if [[ "$numberOfFiles" != "0" ]]; then
    cat customization/docker-compose/*.yml >> docker-compose.yml | true
fi

#if [ ! -f customization/tci-master/tci-master-config.yml.template ]; then
#    cp templates/tci-master/tci-master-config.yml.template customization/tci-master/tci-master-config.yml.template
#fi
cp -n templates/tci-master/*.yml customization/tci-master/ | true
echo after
echo "# PLEASE NOTICE:" > tci-master-config.yml
echo "# This is a generated file, so any change in it will be lost on the next TCI action!" >> tci-master-config.yml
echo "" >> tci-master-config.yml
#cat customization/tci-master/tci-master-config.yml.template >> tci-master-config.yml
numberOfFiles=`ls -1q customization/tci-master/*.yml 2> /dev/null | wc -l | xargs`
cat customization/tci-master/*.yml >> tci-master-config.yml | true
#if [[ "$numberOfFiles" != "0" ]]; then
#    cat customization/tci-master/*.yml >> tci-master-config.yml | true
#fi

mkdir -p .data/jenkins_home/userContent
cp -f images/tci-small-logo.png .data/jenkins_home/userContent | true
sed "s/TCI_MASTER_TITLE_TEXT/${TCI_MASTER_TITLE_TEXT}/ ; s/TCI_MASTER_TITLE_COLOR/${TCI_MASTER_TITLE_COLOR}/ ; s/TCI_MASTER_BANNER_COLOR/${TCI_MASTER_BANNER_COLOR}/" templates/tci-server/tci.css.template > .data/jenkins_home/userContent/tci.css
cp -f templates/tci-server/org.codefirst.SimpleThemeDecorator.xml.template .data/jenkins_home/org.codefirst.SimpleThemeDecorator.xml

if [[ "$action" == "apply" ]]; then
    exit 0
fi

if [ ! -n "$TCI_HOST_IP" ]; then
    export TCI_HOST_IP="$(/sbin/ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1 | sed -e 's/addr://')"
fi
export GIT_PRIVATE_KEY=`cat $GITHUB_PRIVATE_KEY_FILE_PATH`


if [[ "$action" == "info" ]]; then
    echo [Server host IP address] $TCI_HOST_IP
    echo [Private SSH key file path] $GITHUB_PRIVATE_KEY_FILE_PATH
    echo [TCI HTTP port] $JENKINS_HTTP_PORT_FOR_SLAVES
    echo [TCI JNLP port for slaves] $JENKINS_SLAVE_AGENT_PORT
    echo [TCI number of master executors] $JENKINS_ENV_EXECUTERS
    exit 0
fi

if [[ "$action" == "stop" || "$action" == "restart" ]]; then
   docker-compose down --remove-orphans
   sleep 2
fi

if [[ "$action" == "start"  || "$action" == "restart" ]]; then

    docker-compose up -d
    sleep 2
    SECONDS=0
    docker-compose logs -f | while read LOGLINE
    do
        echo "[ET ${SECONDS}s] ${LOGLINE}"
        [[ "${LOGLINE}" == *"Entering quiet mode. Done..."* ]] && pkill -P $$ docker-compose
    done
    action="status"
fi

if [[ "$action" == "status" ]]; then
    status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "403" | wc -l | xargs`
    if [[ "$status" == "1" ]]; then
        echo "[TCI status] tci-server is up and running"
    else
        status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "401" | wc -l | xargs`
        if [[ "$status" == "1" ]]; then
            echo "[TCI status] tci-server is up and running"
        else
            status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "503" | wc -l | xargs`
            if [[ "$status" == "1" ]]; then
                echo "[TCI status] tci-server is starting"
            else
                echo "[TCI status] tci-server is down"
            fi
        fi
    fi
fi

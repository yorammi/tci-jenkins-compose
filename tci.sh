#!/bin/bash

set -e

BG_RED='\033[0;41;93m'
BG_GREEN='\033[0;31;42m'
BLUE='\033[0;94m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

action='restart'
if [[ $# > 0 ]]; then
    action=$1
fi
if [[ "$action" == "upgrade" ]]; then
    rm -rf temp/customization 2> /dev/null | true
    cp -R customization temp 2> /dev/null | true
    rm -rf temp/templates 2> /dev/null | true
    cp -R templates temp 2> /dev/null | true
    if [[ $# > 1 ]]; then
        version=$2
        git checkout $version 2> /dev/null | true
    else
        version=latest
        git checkout master  2> /dev/null | true
        git pull origin master 2> /dev/null | true
    fi
    hash=`git rev-parse --short=8 HEAD`
    mkdir -p info/version
    echo -e "[Version]\t${BLUE}${version}${NC}" > info/version/version.txt
    echo -e "[Hash]\t\t${BLUE}${hash}${NC}" >> info/version/version.txt

    diff1=`diff -q temp/templates/tci-master templates/tci-master | wc -l | xargs`
    diff2=`diff -q temp/customization/tci-master templates/tci-master | wc -l | xargs`
    if [[ "$diff1" != "0" && "$diff2" != "0" ]]; then
        echo -e "\n*** ${BG_RED}NOTE:${NC} You ${BG_RED}MUST${NC} run a tci-master customization merge with new templates ***\n"
        diff -q temp/templates/tci-master templates/tci-master | true
        echo -e "\nFor more information run: ${BLUE}diff temp/templates/tci-master templates/tci-master${NC}\n"
    fi

    echo -e "\n*** ${BG_RED}NOTE:${NC} You need to run again with '${BG_RED}init${NC}' action ***\n"
    exit 0
fi


if [ ! -f tci.config ]; then
    cp templates/tci-server/tci.config.template tci.config
    action='init'
fi

source templates/tci-server/tci.config.template
source tci.config

if [[ "$action" == "init" ]]; then
    echo "Initializing tci-server. For changes to take effect, you'll need to restart the server after that action."
    . ./scripts/init-tci.sh
fi

mkdir -p customization/docker-compose
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

mkdir -p customization/tci-master
cp -n templates/tci-master/*.yml customization/tci-master/ 2> /dev/null | true
echo "# PLEASE NOTICE:" > tci-master-config.yml
echo "# This is a generated file, so any change in it will be lost on the next TCI action!" >> tci-master-config.yml
echo "" >> tci-master-config.yml
numberOfFiles=`ls -1q customization/tci-master/*.yml 2> /dev/null | wc -l | xargs`
cat customization/tci-master/*.yml >> tci-master-config.yml | true

mkdir -p customization/userContent
cp -n templates/userContent/* customization/userContent/ 2> /dev/null | true
sed "s/TCI_MASTER_TITLE_TEXT/${TCI_MASTER_TITLE_TEXT}/ ; s/TCI_MASTER_TITLE_COLOR/${TCI_MASTER_TITLE_COLOR}/ ; s/TCI_MASTER_BANNER_COLOR/${TCI_MASTER_BANNER_COLOR}/" templates/tci-server/tci.css.template > customization/userContent/tci.css
mkdir -p .data/jenkins_home/userContent
cp customization/userContent/* .data/jenkins_home/userContent 2> /dev/null | true

mkdir -p customization/files
cp -n -R templates/files/* customization/files/ 2> /dev/null | true
cp -R customization/files/* . 2> /dev/null | true

#cp -f templates/tci-server/org.codefirst.SimpleThemeDecorator.xml.template .data/jenkins_home/org.codefirst.SimpleThemeDecorator.xml

if [[ "$action" == "apply" ]]; then
    exit 0
fi

if [[ ! -n "$TCI_HOST_IP" || "$TCI_HOST_IP" == "*" ]]; then
    export TCI_HOST_IP="$(/sbin/ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1 | sed -e 's/addr://')"
fi
export GIT_PRIVATE_KEY=`cat $GITHUB_PRIVATE_KEY_FILE_PATH`


if [[ "$action" == "info" ]]; then
    echo -e "\n${BG_RED}[TCI MASTER SERVER INFORMATION]${NC}\n"
    echo -e "[Server host IP address]\t${BLUE}$TCI_HOST_IP${NC}"
    echo -e "[Private SSH key file path]\t${BLUE}$GITHUB_PRIVATE_KEY_FILE_PATH${NC}"
    echo -e "[TCI HTTP port]\t\t\t${BLUE}$JENKINS_HTTP_PORT_FOR_SLAVES${NC}"
    echo -e "[TCI JNLP port for slaves]\t${BLUE}$JENKINS_SLAVE_AGENT_PORT${NC}"
    echo -e "[Number of master executors]\t${BLUE}$JENKINS_ENV_EXECUTERS${NC}"
fi

if [[ "$action" == "info" || "$action" == "version" ]]; then
    if [ -f info/version/version.txt ]; then
        echo -e "\n${BG_RED}[TCI MASTER VERSION INFORMATION]${NC}\n"
        cat info/version/version.txt
    fi
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
        echo -e "${BLUE}[ET:${SECONDS}s]${NC} ${LOGLINE}"
        [[ "${LOGLINE}" == *"Entering quiet mode. Done..."* ]] && pkill -P $$ docker-compose
    done
    action="status"
fi

if [[ "$action" == "status"  || "$action" == "init" ]]; then
    status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "403" | wc -l | xargs`
    if [[ "$status" == "1" ]]; then
        echo -e "${BLUE}[TCI status] ${BG_GREEN}tci-server is up and running${NC}"
    else
        status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "401" | wc -l | xargs`
        if [[ "$status" == "1" ]]; then
            echo -e "${BLUE}[TCI status] ${BG_GREEN}tci-server is up and running${NC}"
        else
            status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "503" | wc -l | xargs`
            if [[ "$status" == "1" ]]; then
                echo -e "${BLUE}[TCI status] ${BG_RED}tci-server is starting${NC}"
            else
                echo -e "${BLUE}[TCI status] ${BG_RED}tci-server is down${NC}"
            fi
        fi
    fi
fi

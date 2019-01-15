#!/bin/bash

set -e

function initTciScript {
    BG_RED='\033[0;41;93m'
    BG_GREEN='\033[0;31;42m'
    BG_BLUE='\033[0;44;93m'
    BLUE='\033[0;94m'
    YELLOW='\033[0;93m'
    NC='\033[0m' # No Color

    rm -rf temp 2> /dev/null | true
}

function usage {
    echo -e "\n${BG_BLUE}TCI command usage${NC}\n"
    echo -e "${BLUE}tci.sh <action> [option]${NC}"
    echo -e "\n  where ${BLUE}<action>${NC} is ..."
    echo -e "\t${BLUE}usage${NC} - show this usage description."
    echo -e "\t${BLUE}version${NC} - show tci-server version information."
    echo -e "\t${BLUE}status${NC} - show tci-server server status & version information."
    echo -e "\t${BLUE}init${NC} - initialize tci-server settings."
    echo -e "\t${BLUE}start${NC} - start the tci-server."
    echo -e "\t${BLUE}stop${NC} - stop the tci-server."
    echo -e "\t${BLUE}restart${NC} - restart the tci-server."
    echo -e "\t${BLUE}apply${NC} - apply changes in the 'setup' folder on the tci-server."
    echo -e "\t${BLUE}upgrade [git-tag]${NC} - upgrage the tci-server version. If no git-tag specified, upgrade to the latest on 'master' branch."
    echo -e "\t${BLUE}log${NC} - tail the docker-compose log."
}

function upgrade {
    if [[ -d customization && ! -d setup ]]; then
        mv customization setup
    fi

    mkdir -p temp 2> /dev/null | true
    rm -rf temp/setup 2> /dev/null | true
    cp -R setup temp/ 2> /dev/null | true
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
    hash=`git rev-parse --short=8 HEAD` 2> /dev/null | true
    mkdir -p info/version
    echo -e "[Version]\t${BLUE}${version}${NC}" > info/version/version.txt
    echo -e "[Hash]\t\t${BLUE}${hash}${NC}" >> info/version/version.txt

    diff1=`diff -q temp/templates/tci-master templates/tci-master | wc -l | xargs`
    diff2=`diff -q temp/setup/tci-master templates/tci-master | wc -l | xargs`
    if [[ "$diff1" != "0" && "$diff2" != "0" ]]; then
        echo -e "\n${BG_RED}NOTE:${NC} You ${BG_RED}MUST${NC} run a tci-master setup merge with new templates."
        echo -e "\nFor more information run: ${BLUE}diff temp/templates/tci-master templates/tci-master${NC}"
        echo -e "\t\t     and: ${BLUE}diff temp/setup/tci-master templates/tci-master${NC}\n"
    fi

    echo -e "\n${BG_RED}NOTE:${NC} You need to run again with '${BG_RED}init${NC}' action\n"
}

function setupTciScript {
    if [ ! -f tci.config ]; then
        cp templates/tci-server/tci.config.template tci.config
        action='init'
    fi

    source templates/tci-server/tci.config.template
    source tci.config

    if [[ "$action" == "init" ]]; then
        echo -e "\n${BLUE}Initializing tci.config file. For changes to take effect, you'll need to restart the server after that action.${NC}\n"
        . ./scripts/init-tci.sh
    fi

    mkdir -p setup/docker-compose
    if [ ! -f setup/docker-compose/docker-compose.yml.template ]; then
        cp templates/docker-compose/docker-compose.yml.template setup/docker-compose/docker-compose.yml.template
    fi
    echo "# PLEASE NOTICE:" > docker-compose.yml
    echo "# This is a generated file, so any change in it will be lost on the next TCI action!" >> docker-compose.yml
    echo "" >> docker-compose.yml
    cat setup/docker-compose/docker-compose.yml.template >> docker-compose.yml
    numberOfFiles=`ls -1q setup/docker-compose/*.yml 2> /dev/null | wc -l | xargs`
    if [[ "$numberOfFiles" != "0" ]]; then
        cat setup/docker-compose/*.yml >> docker-compose.yml | true
    fi

    mkdir -p setup/tci-master
    cp -n templates/tci-master/*.yml setup/tci-master/ 2> /dev/null | true
    echo "# PLEASE NOTICE:" > tci-master-config.yml
    echo "# This is a generated file, so any change in it will be lost on the next TCI action!" >> tci-master-config.yml
    echo "" >> tci-master-config.yml
    numberOfFiles=`ls -1q setup/tci-master/*.yml 2> /dev/null | wc -l | xargs`
    cat setup/tci-master/*.yml >> tci-master-config.yml | true

    mkdir -p setup/userContent
    cp -n templates/userContent/* setup/userContent/ 2> /dev/null | true
    sed "s/TCI_MASTER_TITLE_TEXT/${TCI_MASTER_TITLE_TEXT}/ ; s/TCI_MASTER_TITLE_COLOR/${TCI_MASTER_TITLE_COLOR}/ ; s/TCI_MASTER_BANNER_COLOR/${TCI_MASTER_BANNER_COLOR}/" templates/tci-server/tci.css.template > setup/userContent/tci.css
    mkdir -p .data/jenkins_home/userContent
    cp setup/userContent/* .data/jenkins_home/userContent 2> /dev/null | true

    mkdir -p setup/files
    cp -n -R templates/files/* setup/files/ 2> /dev/null | true
    cp -R setup/files/* . 2> /dev/null | true

    if [[ ! -n "$TCI_HOST_IP" || "$TCI_HOST_IP" == "*" ]]; then
        export TCI_HOST_IP="$(/sbin/ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1 | sed -e 's/addr://')"
    fi

    if [[ "$action" == "init" ]]; then
        exit 0
    fi
}

function info {
    echo -e "\n${BG_BLUE}TCI MASTER SERVER INFORMATION${NC}\n"
    echo -e "[Server host IP address]\t${BLUE}$TCI_HOST_IP${NC}"
    echo -e "[Private SSH key file path]\t${BLUE}$GITHUB_PRIVATE_KEY_FILE_PATH${NC}"
    echo -e "[TCI HTTP port]\t\t\t${BLUE}$JENKINS_HTTP_PORT_FOR_SLAVES${NC}"
    echo -e "[TCI JNLP port for slaves]\t${BLUE}$JENKINS_SLAVE_AGENT_PORT${NC}"
    echo -e "[Number of master executors]\t${BLUE}$JENKINS_ENV_EXECUTERS${NC}"
}

function version {
    if [[ ! -f info/version/version.txt ]]; then
        version=latest
        mkdir -p info/version
        echo -e "[Version]\t${BLUE}${version}${NC}" > info/version/version.txt
        echo -e "[Hash]\t\t${BLUE}${hash}${NC}" >> info/version/version.txt
    fi
    echo -e "\n${BG_BLUE}TCI MASTER VERSION INFORMATION${NC}\n"
    cat info/version/version.txt
}

function stopTciServer {
   docker-compose down --remove-orphans
   sleep 2
}

function startTciServer {
    docker-compose up -d
    sleep 2
}

function showTciServerStatus {
    status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "403" | wc -l | xargs`
    if [[ "$status" == "1" ]]; then
        echo -e "\n${BLUE}[TCI status] ${BG_GREEN}tci-server is up and running${NC}\n"
    else
        status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "401" | wc -l | xargs`
        if [[ "$status" == "1" ]]; then
            echo -e "\n${BLUE}[TCI status] ${BG_GREEN}tci-server is up and running${NC}\n"
        else
            status=`curl -s -I http://localhost:$JENKINS_HTTP_PORT_FOR_SLAVES | grep "503" | wc -l | xargs`
            if [[ "$status" == "1" ]]; then
                echo -e "\n${BLUE}[TCI status] ${BG_RED}tci-server is starting${NC}\n"
            else
                echo -e "\n${BLUE}[TCI status] ${BG_RED}tci-server is down${NC}\n"
            fi
        fi
    fi
}

function tailTciServerLog {
    SECONDS=0
    docker-compose logs -f -t --tail="1"  | while read LOGLINE
    do
        echo -e "${BLUE}[ET:${SECONDS}s]${NC} ${LOGLINE}"
        if [[ $# > 0 && "${LOGLINE}" == *"$1"* ]]; then
            pkill -P $$ docker-compose
        fi
    done
}

initTciScript

if [[ $# > 0 ]]; then
    action=$1
else
    usage
    exit 1
fi

if [[ "$action" == "upgrade" ]]; then
    upgrade
    exit 0
fi

setupTciScript

if [[ "$action" == "apply" ]]; then
    tailTciServerLog "Running update-config.sh. Done"
    exit 0
fi

if [[ "$action" == "info" ]]; then
    info
    exit 0
fi

if [[ "$action" == "info" || "$action" == "version" ]]; then
    version
    info
    exit 0
fi

if [[ "$action" == "status" ]]; then
    showTciServerStatus
    exit 0
fi

if [[ "$action" == "stop" ]]; then
    stopTciServer
    showTciServerStatus
    exit 0
fi

if [[ "$action" == "restart" ]]; then
    stopTciServer
    startTciServer
    tailTciServerLog "Entering quiet mode. Done..."
    showTciServerStatus
    exit 0
fi

if [[ "$action" == "start" ]]; then
    startTciServer
    tailTciServerLog "Entering quiet mode. Done..."
    showTciServerStatus
    exit 0
fi

if [[ "$action" == "log" ]]; then
    tailTciServerLog
    exit 0
fi

usage

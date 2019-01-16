#!/bin/bash

set -e

clear

BG_RED='\033[0;41;93m'
BG_GREEN='\033[0;31;42m'
BG_BLUE='\033[0;44;93m'
BLUE='\033[0;94m'
YELLOW='\033[0;93m'
NC='\033[0m' # No Color

mkdir -p temp
echo "#!/bin/bash" > temp/tci.config
echo -e "" >> temp/tci.config

echo -e -n "tci-master image\n\t[${BLUE}$TCI_MASTER_VERSION${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_VERSION="$REPLY"
fi
echo export TCI_MASTER_VERSION=$TCI_MASTER_VERSION >> temp/tci.config
export TCI_MASTER_VERSION=$TCI_MASTER_VERSION

echo -e -n "tci-library branch\n\t[${BLUE}$TCI_LIBRARY_BRANCH${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_LIBRARY_BRANCH="$REPLY"
fi
echo export TCI_LIBRARY_BRANCH=$TCI_LIBRARY_BRANCH >> temp/tci.config
export TCI_LIBRARY_BRANCH=$TCI_LIBRARY_BRANCH

echo -e -n "tci-pipelines branch\n\t[${BLUE}$TCI_PIPELINES_BRANCH${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_PIPELINES_BRANCH="$REPLY"
fi
echo export TCI_PIPELINES_BRANCH=$TCI_PIPELINES_BRANCH >> temp/tci.config
export TCI_PIPELINES_BRANCH=$TCI_PIPELINES_BRANCH

echo -e -n "TCI banner title\n\t[${BLUE}$TCI_MASTER_TITLE_TEXT${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_TITLE_TEXT="$REPLY"
fi
echo export TCI_MASTER_TITLE_TEXT=\'$TCI_MASTER_TITLE_TEXT\'  >> temp/tci.config
export TCI_MASTER_TITLE_TEXT=\'$TCI_MASTER_TITLE_TEXT\'

echo -e -n "TCI banner title color\n\t[${BLUE}$TCI_MASTER_TITLE_COLOR${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_TITLE_COLOR="$REPLY"
fi
echo export TCI_MASTER_TITLE_COLOR=$TCI_MASTER_TITLE_COLOR  >> temp/tci.config
export TCI_MASTER_TITLE_COLOR=$TCI_MASTER_TITLE_COLOR

echo -e -n "TCI banner background color\n\t[${BLUE}$TCI_MASTER_BANNER_COLOR${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_BANNER_COLOR="$REPLY"
fi
echo export TCI_MASTER_BANNER_COLOR=$TCI_MASTER_BANNER_COLOR  >> temp/tci.config
export TCI_MASTER_BANNER_COLOR=$TCI_MASTER_BANNER_COLOR

echo -e -n "Jenkins server HTTP port\n\t[${BLUE}$JENKINS_HTTP_PORT_FOR_SLAVES${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_HTTP_PORT_FOR_SLAVES="$REPLY"
fi
echo export JENKINS_HTTP_PORT_FOR_SLAVES=$JENKINS_HTTP_PORT_FOR_SLAVES  >> temp/tci.config
export JENKINS_HTTP_PORT_FOR_SLAVES=$JENKINS_HTTP_PORT_FOR_SLAVES

echo -e -n "Jenkins JNLP port for slaves\n\t[${BLUE}$JENKINS_SLAVE_AGENT_PORT${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_SLAVE_AGENT_PORT="$REPLY"
fi
echo export JENKINS_SLAVE_AGENT_PORT=$JENKINS_SLAVE_AGENT_PORT  >> temp/tci.config
export JENKINS_SLAVE_AGENT_PORT=$JENKINS_SLAVE_AGENT_PORT

echo -e -n "Number of exeuters on master\n\t[${BLUE}$JENKINS_ENV_EXECUTERS${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_ENV_EXECUTERS="$REPLY"
fi
echo export JENKINS_ENV_EXECUTERS=$JENKINS_ENV_EXECUTERS >> temp/tci.config
export JENKINS_ENV_EXECUTERS=$JENKINS_ENV_EXECUTERS

echo -e -n "tci in debug mode\n\t[${BLUE}$TCI_DEBUG_MODE${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_DEBUG_MODE="$REPLY"
fi
echo export TCI_DEBUG_MODE=\'$TCI_DEBUG_MODE\' >> temp/tci.config
export TCI_DEBUG_MODE=\'$TCI_DEBUG_MODE\'

echo -e -n "TCI host IP address (set to * for automatic IP calculation)\n\t[${BLUE}$TCI_HOST_IP${NC}]? "
read -r
if [[ "$REPLY" != "" ]]; then
    TCI_HOST_IP="$REPLY"
fi
echo export TCI_HOST_IP=\'$TCI_HOST_IP\'  >> temp/tci.config
export TCI_HOST_IP=\'$TCI_HOST_IP\'

cp temp/tci.config tci.config



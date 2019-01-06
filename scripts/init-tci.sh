#!/bin/bash

set -e

mkdir -p temp
echo "#!/bin/bash" > temp/tci.config
echo -e "" >> temp/tci.config

read -p "tci-master image [$TCI_MASTER_VERSION]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_VERSION="$REPLY"
fi
echo export TCI_MASTER_VERSION=$TCI_MASTER_VERSION >> temp/tci.config
export TCI_MASTER_VERSION=$TCI_MASTER_VERSION

read -p "GitHub private key file path [$GITHUB_PRIVATE_KEY_FILE_PATH]? " -r
if [[ "$REPLY" != "" ]]; then
    GITHUB_PRIVATE_KEY_FILE_PATH="$REPLY"
fi
echo export GITHUB_PRIVATE_KEY_FILE_PATH=$GITHUB_PRIVATE_KEY_FILE_PATH >> temp/tci.config
export GITHUB_PRIVATE_KEY_FILE_PATH=$GITHUB_PRIVATE_KEY_FILE_PATH

read -p "TCI branner title [$TCI_MASTER_TITLE_TEXT]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_TITLE_TEXT="$REPLY"
fi
echo export TCI_MASTER_TITLE_TEXT=\'$TCI_MASTER_TITLE_TEXT\'  >> temp/tci.config
export TCI_MASTER_TITLE_TEXT=\'$TCI_MASTER_TITLE_TEXT\'

read -p "TCI branner title color [$TCI_MASTER_TITLE_COLOR]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_TITLE_COLOR="$REPLY"
fi
echo export TCI_MASTER_TITLE_COLOR=$TCI_MASTER_TITLE_COLOR  >> temp/tci.config
export TCI_MASTER_TITLE_COLOR=$TCI_MASTER_TITLE_COLOR

read -p "TCI banner background color [$TCI_MASTER_BANNER_COLOR]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_MASTER_BANNER_COLOR="$REPLY"
fi
echo export TCI_MASTER_BANNER_COLOR=$TCI_MASTER_BANNER_COLOR  >> temp/tci.config
export TCI_MASTER_BANNER_COLOR=$TCI_MASTER_BANNER_COLOR

read -p "Jenkins server HTTP port [$JENKINS_HTTP_PORT_FOR_SLAVES]? " -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_HTTP_PORT_FOR_SLAVES="$REPLY"
fi
echo export JENKINS_HTTP_PORT_FOR_SLAVES=$JENKINS_HTTP_PORT_FOR_SLAVES  >> temp/tci.config
export JENKINS_HTTP_PORT_FOR_SLAVES=$JENKINS_HTTP_PORT_FOR_SLAVES

read -p "Jenkins JNLP port for slaves [$JENKINS_SLAVE_AGENT_PORT]? " -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_SLAVE_AGENT_PORT="$REPLY"
fi
echo export JENKINS_SLAVE_AGENT_PORT=$JENKINS_SLAVE_AGENT_PORT  >> temp/tci.config
export JENKINS_SLAVE_AGENT_PORT=$JENKINS_SLAVE_AGENT_PORT

read -p "Number of exeuters on master [$JENKINS_ENV_EXECUTERS]? " -r
if [[ "$REPLY" != "" ]]; then
    JENKINS_ENV_EXECUTERS="$REPLY"
fi
echo export JENKINS_ENV_EXECUTERS=$JENKINS_ENV_EXECUTERS >> temp/tci.config
export JENKINS_ENV_EXECUTERS=$JENKINS_ENV_EXECUTERS

read -p "tci in debug mode [$TCI_DEBUG_MODE]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_DEBUG_MODE="$REPLY"
fi
echo export TCI_DEBUG_MODE=\'$TCI_DEBUG_MODE\' >> temp/tci.config
export TCI_DEBUG_MODE=\'$TCI_DEBUG_MODE\'

read -p "TCI host IP address (set to * for automatic IP calculation) [$TCI_HOST_IP]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_HOST_IP="$REPLY"
fi
echo export TCI_HOST_IP='$TCI_HOST_IP'  >> temp/tci.config
export TCI_HOST_IP='$TCI_HOST_IP'

cp temp/tci.config tci.config



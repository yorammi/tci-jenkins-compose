#!/bin/bash

set -e

mkdir -p temp
echo "#!/bin/bash" > temp/tci.config
echo -e "" >> temp/tci.config

read -p "GitHub private key file path [$GITHUB_PRIVATE_KEY_FILE_PATH]? " -r
if [[ "$REPLY" != "" ]]; then
    GITHUB_PRIVATE_KEY_FILE_PATH="$REPLY"
fi
echo export GITHUB_PRIVATE_KEY_FILE_PATH=$GITHUB_PRIVATE_KEY_FILE_PATH >> temp/tci.config
export GITHUB_PRIVATE_KEY_FILE_PATH=$GITHUB_PRIVATE_KEY_FILE_PATH

read -p "TCI branner title [$TCI_SERVER_TITLE_TEXT]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_SERVER_TITLE_TEXT="$REPLY"
fi
echo export TCI_SERVER_TITLE_TEXT=\'$TCI_SERVER_TITLE_TEXT\'  >> temp/tci.config
export TCI_SERVER_TITLE_TEXT=\'$TCI_SERVER_TITLE_TEXT\'

read -p "TCI branner title color [$TCI_SERVER_TITLE_COLOR]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_SERVER_TITLE_COLOR="$REPLY"
fi
echo export TCI_SERVER_TITLE_COLOR=$TCI_SERVER_TITLE_COLOR  >> temp/tci.config
export TCI_SERVER_TITLE_COLOR=$TCI_SERVER_TITLE_COLOR

read -p "TCI branner background color [$TCI_BANNER_COLOR]? " -r
if [[ "$REPLY" != "" ]]; then
    TCI_BANNER_COLOR="$REPLY"
fi
echo export TCI_BANNER_COLOR=$TCI_BANNER_COLOR  >> temp/tci.config
export TCI_BANNER_COLOR=$TCI_BANNER_COLOR

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

#read -p "TCI host IP address [$TCI_HOST_IP]? " -r
#if [[ "$REPLY" != "" ]]; then
#    TCI_HOST_IP="$REPLY"
#fi
#echo export TCI_HOST_IP=$TCI_HOST_IP  >> temp/tci.config
#export TCI_HOST_IP=$TCI_HOST_IP
#export TCI_HOST_IP=

cp temp/tci.config tci.config



FROM docker:latest

#ARG TCI_MASTER_VERSION=tikalci/tci-master-minimal:lts
#ARG TCI_MASTER_TITLE_TEXT='TCI'
#ARG TCI_MASTER_TITLE_COLOR=orange
#ARG TCI_MASTER_BANNER_COLOR=darkblue
#ARG JENKINS_HTTP_PORT_FOR_SLAVES=8080
#ARG JENKINS_SLAVE_AGENT_PORT=50000
#ARG JENKINS_ENV_EXECUTERS=0
#ARG TCI_HOST_IP=0.0.0.0

RUN apk update
RUN apk add py-pip
RUN apk add bash
RUN pip install bash docker-compose

COPY templates /templates
COPY scripts /scripts
COPY tci.sh /
RUN cp -r /templates /setup
RUN cp /templates/tci-server/tci.config.template /tci.config
RUN source /tci.config

CMD ./tci.sh start
EXPOSE 8080
EXPOSE 50000

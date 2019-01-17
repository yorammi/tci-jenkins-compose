FROM docker:latest

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

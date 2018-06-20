# Dockerfile for appsensor-reverse-proxy

FROM golang:1.10.3-alpine3.7

MAINTAINER John Melton <jtmelton@gmail.com>

# default values override with -e
ENV APPSENSOR_REST_ENGINE_URL=http://localhost:8085
ENV APPSENSOR_CLIENT_APPLICATION_ID_HEADER_NAME=X-Appsensor-Client-Application-Name
ENV APPSENSOR_CLIENT_APPLICATION_ID_HEADER_VALUE=reverse-proxy
ENV APPSENSOR_CLIENT_APPLICATION_IP_ADDRESS=127.0.0.1

# using ENV to allow dynamic loading of configuration files
ENV resource-verbs-mapping-file=testdata/sample-resource-verbs-mapping.yml
ENV resources-file=testdata/sample-resources.yml

RUN go get github.com/tools/godep

WORKDIR /go/src/appsensor-reverse-proxy
COPY ..
RUN godep restore
RUN go install

# add config files
COPY $resource-verbs-mapping-file /tmp/resource-verbs-mapping.xml
COPY $resources-file /tmp/resources.yml

# cli args can be sent through as expected
ENTRYPOINT ["/go/bin/proxy", "-resource-verbs-mapping-file=/tmp/resource-verbs-mapping.xml", "-resources-file=/tmp/resources.yml"]

# if no cli args, default of -help is sent
CMD ["-help"]
# this is the default port to run appsensor-reverse-proxy on
EXPOSE 8080


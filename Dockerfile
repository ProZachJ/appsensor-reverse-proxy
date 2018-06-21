# Dockerfile for appsensor-reverse-proxy

FROM golang:1.9-alpine3.7

MAINTAINER John Melton <jtmelton@gmail.com>

# default values override with -e
ENV APPSENSOR_REST_ENGINE_URL=http://localhost:8085
ENV APPSENSOR_CLIENT_APPLICATION_ID_HEADER_NAME=X-Appsensor-Client-Application-Name
ENV APPSENSOR_CLIENT_APPLICATION_ID_HEADER_VALUE=reverse-proxy
ENV APPSENSOR_CLIENT_APPLICATION_IP_ADDRESS=127.0.0.1

# using ENV to allow dynamic loading of configuration files
ENV resource-verbs-mapping-file=testdata/sample-resource-verbs-mapping.yml
ENV resources-file=testdata/sample-resources.yml

WORKDIR /go

RUN apk add --no-cache git mercurial \
    && go get github.com/tools/godep \
	&& go get gopkg.in/yaml.v2

COPY . src/appsensor-reverse-proxy
WORKDIR /go/src/appsensor-reverse-proxy
RUN go get
RUN go install

# add config files
RUN cp testdata/sample-resource-verbs-mapping.yml /tmp/resource-verbs-mapping.xml
RUN cp testdata/sample-resources.yml /tmp/resources.yml

RUN ls /go/bin
# cli args can be sent through as expected
ENTRYPOINT ["/go/bin/appsensor-reverse-proxy", "-resource-verbs-mapping-file=/tmp/resource-verbs-mapping.xml", "-resources-file=/tmp/resources.yml"]

# if no cli args, default of -help is sent
CMD ["-help"]
# this is the default port to run appsensor-reverse-proxy on
EXPOSE 8080


FROM alpine:latest

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN  apk -U upgrade --update && \
        apk --no-cache add openjdk11 && \
        apk --no-cache add bash

ENV TOMCAT_MAJOR=9 \
    TOMCAT_VERSION=9.0.43 \
    CATALINA_HOME=/opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN apk add curl && \
    apk add ttf-dejavu

RUN mkdir -p /opt

RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME

RUN apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

WORKDIR $CATALINA_HOME

COPY Puzzle15-1.0-SNAPSHOT.war /opt/tomcat/webapps/Puzzle15-1.0-SNAPSHOT.war

EXPOSE 8080

ENTRYPOINT ["catalina.sh", "run" ]


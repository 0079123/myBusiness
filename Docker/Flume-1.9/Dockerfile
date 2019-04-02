FROM debian:stable
MAINTAINER hhyykk<hhyykk0083@gmail.com>
ARG FLUME_VERSION=1.9.0

RUN apt-get update -y && \
  apt-get install -y default-jre && apt-get clean all && rm -rf /var/cache/apt-get && \
  curl -L http://archive.apache.org/dist/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz | tar xz && \
  mv apache-flume-${FLUME_VERSION}-bin apache-flume && \
  cp /apache-flume/conf/flume-conf.properties.template /apache-flume/conf/flume-conf.properties

ENV JAVA_HOME=/usr
ENV AGENT=agent

WORKDIR /apache-flume

CMD [ "sh","-c", "./bin/flume-ng agent -n ${AGENT} -c conf -f conf/flume-conf.properties" ]

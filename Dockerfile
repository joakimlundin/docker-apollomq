# From Ubuntu base image
FROM ubuntu:14.04

# Install java
RUN \
   echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
   apt-get update && \
   apt-get install -y software-properties-common && \
   add-apt-repository -y ppa:webupd8team/java && \
   apt-get update && \
   apt-get install -y oracle-java8-installer && \
   rm -rf /var/lib/apt/lists/* && \
   rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Create Apollo user
RUN useradd -m apollo

# Install Apollo MQ
ENV APOLLO_ROOT /opt/apollo
WORKDIR ${APOLLO_ROOT}
ADD --chown=apollo:apollo http://apache.mirrors.spacedump.net/activemq/activemq-apollo/1.7.1/apache-apollo-1.7.1-unix-distro.tar.gz ${APOLLO_ROOT}
RUN tar -zxvf apache-apollo-1.7.1-unix-distro.tar.gz && \
   rm apache-apollo-1.7.1-unix-distro.tar.gz

# Create broker instance
ENV APOLLO_HOME ${APOLLO_ROOT}/apache-apollo-1.7.1
ENV BROKER_HOME /var/lib/brokers
WORKDIR ${BROKER_HOME}
RUN \
   chown apollo:apollo ${BROKER_HOME} && \
   ${APOLLO_HOME}/bin/apollo create apollo-broker
ADD apollo.xml apollo-boker/etc/
   
# Expose standard ports
EXPOSE 61613 61614 61623 61624 61680 61681 5672 5671

# Execute
USER apollo
CMD apollo-broker/bin/apollo-broker run

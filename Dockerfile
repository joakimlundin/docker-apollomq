# From OpenJDK base image
FROM openjdk:8-jre-slim

# Create Apollo user
RUN useradd -m apollo

# Install Apollo MQ
ARG APOLLO_ROOT=/opt/apollo
WORKDIR ${APOLLO_ROOT}
ADD --chown=apollo:apollo http://apache.mirrors.spacedump.net/activemq/activemq-apollo/1.7.1/apache-apollo-1.7.1-unix-distro.tar.gz ${APOLLO_ROOT}
RUN tar -zxvf apache-apollo-1.7.1-unix-distro.tar.gz && \
   rm apache-apollo-1.7.1-unix-distro.tar.gz

# Create broker instance
ARG APOLLO_HOME=${APOLLO_ROOT}/apache-apollo-1.7.1
ARG BROKER_HOME=/var/lib/brokers
WORKDIR ${BROKER_HOME}
RUN ${APOLLO_HOME}/bin/apollo create apollo-broker
ADD apollo.xml apollo-broker/etc/
ADD log4j.properties apollo-broker/etc/
RUN chown -R apollo:apollo ${BROKER_HOME}

# Update JVM heap space
RUN sed -i 's/^#export JVM_FLAGS=.*$/export JVM_FLAGS="-server -Xms7G -Xmx7G"/' ${BROKER_HOME}/apollo-broker/bin/apollo-broker

# Mount data directory
VOLUME ${BROKER_HOME}/apollo-broker/data

# Expose standard ports
EXPOSE 61680 5672

# Execute
USER apollo
CMD apollo-broker/bin/apollo-broker run

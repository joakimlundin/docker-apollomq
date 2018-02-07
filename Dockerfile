# From OpenJDK base image
FROM openjdk:8-jre-slim

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
RUN ${APOLLO_HOME}/bin/apollo create apollo-broker
ADD apollo.xml apollo-broker/etc/
ADD users.properties apollo-broker/etc/
ADD groups.properties apollo-broker/etc/
RUN chown -R apollo:apollo ${BROKER_HOME}
 
# Mount data directory
VOLUME ${BROKER_HOME}/apollo-broker/data

# Expose standard ports
EXPOSE 61680 5672

# Execute
USER apollo
CMD apollo-broker/bin/apollo-broker run

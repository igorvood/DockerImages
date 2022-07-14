FROM openjdk
 
ARG brokerId=1
 
ADD kafka_2.13-3.2.0.tgz /
 
RUN mv /kafka_2.13-3.2.0.tgz /kafka && \
    sed -i s/localhost:2181/zookeeper:2181/g /kafka/config/server.properties && \
    sed -i s/broker.id=0/broker.id=${brokerId}/g /kafka/config/server.properties
 
EXPOSE 2181 9092

FROM  ubuntu:16.04

RUN apt -y update && \
    apt -y install curl openjdk-8-jdk git maven npm r-base-dev && \
    R -e 'install.packages("knitr", repos = "https://cloud.r-project.org/")' && \
    apt clean

ARG uid=1000
ARG user=ubuntu
RUN useradd -m -u $uid $user
USER $user
WORKDIR /home/$user

RUN git clone https://github.com/apache/incubator-zeppelin.git && \
    cd incubator-zeppelin && \
    mvn clean package -Pspark-1.6 -Dhadoop.version=2.6.0-cdh5.7.0 -Phadoop-2.6 -Pvendor-repo -Psparkr -Pbuild-distr -DskipTests \
     -pl '!livy,!hive,!hbase,!phoenix,!tajo,!flink,!ignite,!kylin,!lens,!cassandra,!alluxio' && \
    cd ~ && \
    tar xf incubator-zeppelin/zeppelin-distribution/target/*.tar.gz && \
    mv zeppelin* zeppelin && \
    rm -r incubator-zeppelin .m2

EXPOSE 8080

CMD zeppelin/bin/zeppelin.sh

FROM amazoncorretto:8u442-alpine3.21-jre

ARG HADOOP_VERSION=3.3.6
ARG HIVE_METASTORE_VERSION=3.0.0
ARG POSTGRES_CONNECTOR_VERSION=42.7.2
ARG AWS_SDK_VERSION=1.12.540 # You can adjust this version
ARG HADOOP_AWS_VERSION=${HADOOP_VERSION} # Assuming Hadoop AWS version matches Hadoop

WORKDIR /app
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apk update && apk upgrade && apk add net-tools gettext curl

RUN echo "Download and extract the Hadoop binary package" && \
    curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    | tar xvz -C /opt/ && \
    ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop && \
    rm -r /opt/hadoop/share/doc

RUN echo "Download and install Hadoop AWS S3 libraries" && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/$HADOOP_AWS_VERSION/hadoop-aws-$HADOOP_AWS_VERSION.jar -o /opt/hadoop/share/hadoop/common/lib/hadoop-aws-$HADOOP_AWS_VERSION.jar && \
    curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/$AWS_SDK_VERSION/aws-java-sdk-bundle-$AWS_SDK_VERSION.jar -o /opt/hadoop/share/hadoop/common/lib/aws-java-sdk-bundle-$AWS_SDK_VERSION.jar && \
    ln -s /opt/hadoop/share/hadoop/common/lib/hadoop-aws-$HADOOP_AWS_VERSION.jar /opt/hadoop/share/hadoop/hdfs/lib/ && \
    ln -s /opt/hadoop/share/hadoop/common/lib/aws-java-sdk-bundle-$AWS_SDK_VERSION.jar /opt/hadoop/share/hadoop/hdfs/lib/

RUN echo "Download and install the standalone metastore binary" && \
    curl https://downloads.apache.org/hive/hive-standalone-metastore-$HIVE_METASTORE_VERSION/hive-standalone-metastore-$HIVE_METASTORE_VERSION-bin.tar.gz \
    | tar xvz -C /opt/ && \
    ln -s /opt/apache-hive-metastore-$HIVE_METASTORE_VERSION-bin /opt/hive-metastore

RUN echo "Copy Hadoop AWS S3 libraries to Hive Metastore lib directory" && \
    cp /opt/hadoop/share/hadoop/common/lib/hadoop-aws-$HADOOP_AWS_VERSION.jar /opt/hive-metastore/lib/ && \
    cp /opt/hadoop/share/hadoop/common/lib/aws-java-sdk-bundle-$AWS_SDK_VERSION.jar /opt/hive-metastore/lib/

RUN echo "Fix 'java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument'" && \
    echo "Keep this until this lands: https://issues.apache.org/jira/browse/HIVE-22915" && \
    rm /opt/apache-hive-metastore-$HIVE_METASTORE_VERSION-bin/lib/guava-19.0.jar && \
    cp /opt/hadoop-$HADOOP_VERSION/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/apache-hive-metastore-$HIVE_METASTORE_VERSION-bin/lib/

RUN echo "Download and install the database connector" && \
    curl -L https://jdbc.postgresql.org/download/postgresql-$POSTGRES_CONNECTOR_VERSION.jar --output /opt/postgresql-$POSTGRES_CONNECTOR_VERSION.jar && \
    ln -s /opt/postgresql-$POSTGRES_CONNECTOR_VERSION.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/postgresql-$POSTGRES_CONNECTOR_VERSION.jar /opt/hive-metastore/lib/

RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/jackson-databind-2.9.4.jar
RUN echo "Download and install the updated jackson-databind" && \
    curl -L https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.9.7/jackson-databind-2.9.7.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/jackson-databind-2.9.7.jar

RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/derby-10.10.2.0.jar
RUN echo "Download and install the updated derby" && \
    curl -L https://repo1.maven.org/maven2/org/apache/derby/derby/10.14.3/derby-10.14.3.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/derby-10.14.3.jar

RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-1.2-api-2.8.2.jar
RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-api-2.8.2.jar
RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-core-2.8.2.jar
RUN rm /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-slf4j-impl-2.8.2.jar
RUN echo "Download and install the updated log4j libraries" && \
    curl -L https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.16.0/log4j-1.2-api-2.16.0.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-1.2-api-2.16.0.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.16.0/log4j-api-2.16.0.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-api-2.16.0.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.16.0/log4j-core-2.16.0.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-core-2.16.0.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-slf4j-impl/2.16.0/log4j-slf4j-impl-2.16.0.jar --output /opt/apache-hive-metastore-3.0.0-bin/lib/log4j-slf4j-impl-2.16.0.jar

RUN rm /opt/hadoop-3.3.6/share/hadoop/hdfs/lib/avro-1.7.7.jar
RUN rm /opt/hadoop-3.3.6/share/hadoop/common/lib/avro-1.7.7.jar
RUN echo "Download and install the updated avro" && \
    curl -L https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.4/avro-1.11.4.jar -o /opt/hadoop-3.3.6/share/hadoop/hdfs/lib/avro-1.11.4.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/avro/avro/1.11.4/avro-1.11.4.jar -o /opt/hadoop-3.3.6/share/hadoop/common/lib/avro-1.11.4.jar

RUN rm /opt/hadoop-3.3.6/share/hadoop/yarn/timelineservice/lib/htrace-core-3.1.0-incubating.jar
RUN rm /opt/hadoop-3.3.6/share/hadoop/client/hadoop-client-runtime-3.3.6.jar
RUN rm /opt/hadoop-3.3.6/share/hadoop/yarn/hadoop-yarn-applications-catalog-webapp-3.3.6.war

RUN apk add --no-cache bash

COPY hive-site.xml hive-site_TEMPLATE.xml
COPY metastore-site.xml metastore-site_TEMPLATE.xml
COPY core-site.xml core-site_TEMPLATE.xml
COPY --chmod=755 run.sh run.sh

ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/hadoop/bin:${PATH}"
ENV METASTORE_PORT=9083
ENV DATABASE_DRIVER=org.postgresql.Driver
ENV DATABASE_TYPE=postgres
ENV DATABASE_TYPE_JDBC=postgresql
ENV DATABASE_PORT=5432
ENV DATABASE_USER=postgres
ENV DATABASE_PASSWORD=fkRXDXjgSbwvg9IUa1fe
ENV DATABASE_DB=metastore
ENV DATABASE_HOST=database-1.cv0mmcsqql0c.us-west-2.rds.amazonaws.com

CMD [ "./run.sh" ]
HEALTHCHECK CMD [ "sh", "-c", "netstat -ln | grep 9083" ]
FROM adoptopenjdk/maven-openjdk11:latest

RUN apt-get update && apt-get install --yes \
  python-dev \
  unzip

# AWS CLI is used to push the JAR to s3
RUN curl --silent --output awscli-bundle.zip \
  https://aws-cli.s3.amazonaws.com/awscli-bundle.zip && \
  unzip awscli-bundle.zip && \
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

WORKDIR /usr/src/kafka-connect-connectors
COPY . /usr/src/kafka-connect-connectors
RUN mvn install package


FROM eclipse-temurin:17-jdk-jammy

RUN apt-get update && apt-get install -y unzip curl

RUN curl -LO https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip \
    && unzip dependency-check-8.4.0-release.zip -d /opt \
    && ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check.sh
# Production-grade OWASP Dependency-Check Dockerfile
FROM eclipse-temurin:17-jdk-jammy

# Install required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        unzip \
        ca-certificates \
        gosu && \
    rm -rf /var/lib/apt/lists/*

# Set Dependency-Check version and data directory
ARG DC_VERSION=12.1.3
ENV DC_VERSION=${DC_VERSION}
ENV DC_HOME=/opt/dependency-check
ENV DC_DATA_DIR=/opt/dc-data

# Download and install Dependency-Check CLI
RUN curl -L -o /tmp/dc.zip "https://github.com/dependency-check/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip" \
    && unzip /tmp/dc.zip -d /opt \
    && mv /opt/dependency-check /opt/dependency-check-${DC_VERSION} \
    && ln -s /opt/dependency-check-${DC_VERSION} ${DC_HOME} \
    && ln -s ${DC_HOME}/bin/dependency-check.sh /usr/local/bin/dependency-check.sh \
    && rm /tmp/dc.zip

# Pre-download the NVD database for faster scans in CI
ARG NVD_API_KEY
RUN mkdir -p $DC_DATA_DIR && \
    NVD_API_KEY=$NVD_API_KEY dependency-check.sh --data $DC_DATA_DIR --nvdApiKey $NVD_API_KEY --updateonly || (echo "Dependency-Check DB update failed" && ls -l $DC_DATA_DIR) && \
    unset NVD_API_KEY

# Ensure /bin/sh points to bash for shell compatibility
RUN ln -sf /bin/bash /bin/sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"] 

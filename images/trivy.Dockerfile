ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN microdnf install \
    gzip \
    tar

RUN curl -LO https://github.com/aquasecurity/trivy/releases/download/v0.25.4/trivy_0.25.4_Linux-64bit.tar.gz && \
    tar xf trivy_0.25.4_Linux-64bit.tar.gz && \
    install trivy /usr/local/bin/trivy && \
    rm trivy trivy_0.25.4_Linux-64bit.tar.gz
ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 && \
    install sops-v3.7.3.linux.amd64 /usr/local/bin/sops && \
    rm sops-v3.7.3.linux.amd64

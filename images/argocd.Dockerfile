ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN microdnf install openssh-clients

RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd
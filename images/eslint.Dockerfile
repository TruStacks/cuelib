ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN microdnf module disable nodejs:10 && \
    microdnf module enable nodejs:16

RUN microdnf install \
    nodejs \
    jq

RUN npm i -g eslint

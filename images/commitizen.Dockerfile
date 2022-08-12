ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN microdnf install \
    bash \
    git \
    python3 \
    python3-pip

RUN pip3 install commitizen

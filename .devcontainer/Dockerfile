ARG VARIANT="8.5"
FROM registry.access.redhat.com/ubi8/ubi:${VARIANT}

RUN dnf install -y \
    git \
    gzip \
    make \
    sudo \
    tar \
    xz

# install dagger
RUN cd /usr/local && \
    curl -L https://dl.dagger.io/dagger/install.sh | sh

# install nodejs
RUN curl -Lo /tmp/node.tar.xz https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz && \
    tar xf /tmp/node.tar.xz && \
    sudo mv node-v16.15.1-linux-x64 /opt/node

ENV PATH=$PATH:/opt/node/bin

# install bats
RUN curl -Lo /tmp/bats.tar.gz https://github.com/bats-core/bats-core/archive/refs/tags/v1.7.0.tar.gz && \
    tar xf /tmp/bats.tar.gz && \
    sudo mv bats-core-1.7.0 /opt/bats && \
    sudo ln -s /opt/bats/bin/bats /usr/local/bin/bats && \
    mkdir /tmp/bats && \
    curl -Lo /tmp/bats/bats_helpers.bash https://raw.githubusercontent.com/dagger/dagger/main/pkg/universe.dagger.io/bats_helpers.bash && \
    curl -Lo /tmp/bats/package.json https://raw.githubusercontent.com/dagger/dagger/main/pkg/universe.dagger.io/package.json && \
    cd /tmp/bats && sudo /opt/node/bin/npm install

RUN useradd trustacks
RUN echo "trustacks ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/trustacks

USER trustacks:0
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
RUN npm -g install bats

RUN useradd trustacks
RUN echo "trustacks ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/trustacks

USER trustacks:0
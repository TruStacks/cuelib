ARG VERSION="8.5"
FROM "registry.access.redhat.com/ubi8/ubi-minimal:$VERSION"

RUN microdnf module disable nodejs:10 && \
    microdnf module enable nodejs:16

RUN microdnf install \ 
    nodejs \
    git \
    gzip \
    jq \
    tar

RUN npm i -g yarn

RUN curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh  | bash && \
    install ./kustomize /usr/local/bin/kustomize && \
    rm ./kustomize

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

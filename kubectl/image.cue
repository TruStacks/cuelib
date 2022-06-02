package kubectl

import (
    "universe.dagger.io/docker"
)

_#DefaultVersion: "8.5"

#Image: {
    version: *_#DefaultVersion | string

    docker.#Build & {
        steps: [
            docker.#Pull & {
                source: "registry.access.redhat.com/ubi8/ubi-minimal:\(version)"
            },
            docker.#Run & {
                command: {
                    name:  "/bin/sh"
                    args:  [
                        #"""
                        curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
                        install kubectl /usr/local/bin/kubectl
                        """#
                    ]
                    flags: "-c": true
                }
            }
        ]
    }
}
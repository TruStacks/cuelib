package sops

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
                        curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 && \
                        install sops-v3.7.3.linux.amd64 /usr/local/bin/sops && \
                        rm sops-v3.7.3.linux.amd64
                        """#
                    ]
                    flags: "-c": true
                }
            }
        ]
    }
}
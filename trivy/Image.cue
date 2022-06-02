package trivy

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
                    name: "microdnf"
                    args: ["install", "gzip", "tar"]
                }
            },
            docker.#Run & {
                command: {
                    name:  "/bin/sh"
                    args:  [
                        #"""
                        curl -LO https://github.com/aquasecurity/trivy/releases/download/v0.25.4/trivy_0.25.4_Linux-64bit.tar.gz && \
                        tar xf trivy_0.25.4_Linux-64bit.tar.gz && \
                        install trivy /usr/local/bin/trivy && \
                        rm trivy trivy_0.25.4_Linux-64bit.tar.gz
                        """#
                    ]
                    flags: "-c": true
                }
            }
        ]
    }
}
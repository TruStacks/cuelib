package flux2

import (
    "universe.dagger.io/docker"
)

_#DefaultVersion: "8.6"

#Image: {
    version: *_#DefaultVersion | string

    docker.#Build & {
        steps: [
            docker.#Pull & {
                source: "registry.access.redhat.com/ubi8/ubi-minimal:\(version)"
            },
            docker.#Run & {
                command: {
                    name: "/bin/bash"
                    args: [
                        "-c", 
                        #"""
                        microdnf install gzip tar which
                        curl -s https://fluxcd.io/install.sh | bash
                        """#
                    ]
                }
            }
        ]
    }
}
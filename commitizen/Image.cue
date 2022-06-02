package commitizen

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
                    args: ["install", "bash", "git", "python3", "python3-pip"]
                }
            },
            docker.#Run & {
                command: {
                    name:  "pip3"
                    args:  ["install", "commitizen"]
                }
            }
        ]
    }
}
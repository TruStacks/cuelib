package eslint

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
                    args: ["module", "disable", "nodejs:10"]
                }
            },
            docker.#Run & {
                command: {
                    name: "microdnf"
                    args: ["module", "enable", "nodejs:16"]
                }
            },
            docker.#Run & {
                command: {
                    name: "microdnf"
                    args: ["install", "nodejs", "jq"]
                }
            },
            docker.#Run & {
                command: {
                    name:  "npm"
                    args:  ["i", "eslint"]
                    flags: "-g": true
                }
            }
        ]
    }
}
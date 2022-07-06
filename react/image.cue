package react

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
                    args: ["install", "nodejs", "git", "gzip", "jq", "tar"]
                }
            },
            docker.#Run & {
                command: {
                    name:  "npm"
                    args:  ["install", "yarn"]
                    flags: "-g": true
                }
            },
            docker.#Run & {
                command: {
                    name:  "/bin/sh"
                    args:  [
                        #"""
                        curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh  | bash
                        install ./kustomize /usr/local/bin/kustomize
                        rm ./kustomize

                        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        """#
                    ]
                    flags: "-c": true
                }
            }
        ]
    }
}
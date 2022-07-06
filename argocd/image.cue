package argocd

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
                    name: "microdnf"
                    args: ["install", "openssh-clients"]
                }
            },
            docker.#Run & {
                command: {
                    name: "/bin/bash"
                    args: [
                        "-c", 
                        #"""
                        curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                        chmod +x /usr/local/bin/argocd
                        """#
                    ]
                }
            }
        ]
    }
}
package react

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"

    "universe.dagger.io/docker"
)

// Build the application container.
#Containerize: {
    // The project source code.
    source: dagger.#FS

    // The image tag.
    tag: string

    // The directory with the docker build dependencies.
    depsDir: string | *".trustacks"

    // The project build static assets.
    build: dagger.#FS

    // The container image.
    image: container.output

    // The container filesystem.
    output: _export.output

    container: docker.#Build & {
        steps: [
            docker.#Pull & {
                source: "registry.access.redhat.com/ubi8/ubi-minimal"
            },
            docker.#Run & {
                command: {
                    name: "microdnf"
                    args: ["install", "nginx"]
                }
            },
            docker.#Copy & {
                dest:     "/usr/share/nginx/html"
                contents: build
            },
            docker.#Copy & {
                "source": "\(depsDir)/nginx.conf"
                dest:     "/etc/nginx/nginx.conf"
                contents: source
            },
            docker.#Set & {
                config: {
                    cmd: ["nginx", "-g", "'daemon off;'"]
                }
            }
        ]
    }

    _export: core.#Export & {
        "tag":  tag
		input:  container.output.rootfs
        config: container.output.config
	}
}
package react

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"

    "universe.dagger.io/docker"
)

// Build the application container.
#Containerize: {
    // Image tag.
    tag: string

    // Docker build assets.
    assets: dagger.#FS

    // Project build static assets.
    build: dagger.#FS

    // Container image.
    image: container.output

    // Container filesystem.
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
                "source": "/nginx.conf"
                dest:     "/etc/nginx/conf.d/app.conf"
                contents: assets
            },
            docker.#Set & {
                config: {
                    cmd: ["/bin/sh", "-c", "nginx -g 'daemon off;'"]
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
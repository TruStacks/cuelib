package kubectl

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Create a kubernetes container registry secret.
#DockerRegistry: {
    // Secret name.
    name: string

    // Secret namespace.
    namespace: string

    // Container registry server.
    server: string

    // Container registry username.
    username: string

    // Container registry password.
    password: dagger.#Secret

    // Run the command in dry-run mode.
    dryRun: string | *"none"

    // Other actions required to run before this one.
    requires: [...string]

    // command exit code.
	code: container.export.files."/code"

    // The kubernetes docker registry secret.
    output: container.export.directories."/output"

    container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        set -x
        mkdir /output
        kubectl create secret docker-registry $NAME \
            --dry-run=$DRY_RUN \
            --docker-server=$SERVER \
            --docker-username=$USERNAME \
            --docker-password=$PASSWORD \
            -o yaml \
            -n $NAMESPACE \
        | tee /output/secret.yaml
        echo $$ > /code
        """#

        export: {
            directories: "/output": _
            files:       "/code": string
        }

        env: {
            DRY_RUN:   dryRun
            NAME:      name
            NAMESPACE: namespace
            SERVER:    server
            USERNAME:  username
            PASSWORD:  password
            REQUIRES:  strings.Join(requires, "_")
        }
    }
}

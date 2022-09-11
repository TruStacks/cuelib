package react

import (
    "strings"

    "dagger.io/dagger"
    // "dagger.io/dagger/core"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Push the image to the docker registry.
#Publish: {
    // Container image to publish.
    image: docker.#Image

    // Source input.
    input: dagger.#FS

    // Image tag.
    ref: string

    // Container registry username
    registryUsername: string

    // Container registry password.
    registryPassword: dagger.#Secret

    // Other actions required to run before this one.
    requires: [...string]
    
    // Export input source for execution order control.
    output: _container.export.directories."/output"
    
    // Hack for requirements ordering
    _container: bash.#Run & {
        _image:  #Image
        "input": _image.output
        workdir: "/src"
        script: contents: #"""
        cp -R /src /output
        echo "$REF" > /ref
        cat /ref
        """#
        
        env: {
            REQUIRES: strings.Join(requires, "_")
            REF: ref 
        }

        mounts: {
            "src": {
                dest:     "/src"
                contents: input
            }
        }

        export: {
            files:       "/ref": string
            directories: "/output": dagger.#FS
        }
    }

    docker.#Push & {
        // Registry authentication
        auth: {
            "username": registryUsername
            secret:     registryPassword
        }
        dest:    strings.TrimSpace(_container.export.files."/ref")
        "image": image 
    }
}
package react

import (
    "strings"

    "dagger.io/dagger"

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
    username: string

    // Container registry password.
    password: dagger.#Secret

    // Other actions required to run before this one.
    requires: [...string]
    
    output: container.export.directories."/output"

    // Registry authentication
	auth?: {
		"username": username
		secret:     password
	}
    
    // Hack for requirements ordering
    container: bash.#Run & {
        _image:  #Image
        "input": _image.output
        workdir: "/src"
        script: contents: #"""
        cp -R /src /output
        echo "$REF" > /ref
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
        dest:    strings.TrimSpace(container.export.files."/ref")
        "auth":  auth
        "image": image
    }
}
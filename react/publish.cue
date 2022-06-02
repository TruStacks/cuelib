package react

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Push the image to the docker registry.
#Publish: {
    // The container image to publish.
    image: docker.#Image

    // The image tag.
    ref: string

    // The container registry username
    username: string

    // The container registry password.
    password: dagger.#Secret

    // Other actions required to run before this one.
    requires: [...string]
    
    // Registry authentication
	auth?: {
		"username": username
		secret:     password
	}
    
    // Hack for requirements ordering
    bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"
        script: contents: ""
        env: REQUIRES: strings.Join(requires, "_")
    }

    docker.#Push & {
        dest:    ref
        "auth":  auth
        "image": image
    }
}
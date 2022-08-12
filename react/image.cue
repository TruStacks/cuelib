package react

import (
    "universe.dagger.io/docker"
)

#Image: {
    docker.#Pull & {
        source: "quay.io/trustacks/cuelib-react"
    }
}
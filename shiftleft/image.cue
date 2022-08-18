package shiftleft

import (
    "universe.dagger.io/docker"
)

#Image: {
    docker.#Pull & {
        source: "shiftleft/scan"
    }
}
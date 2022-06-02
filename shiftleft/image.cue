package shiftleft

import (
    "universe.dagger.io/docker"
)

#Image: {
    output: _image.output

    _image: docker.#Pull & {
        source: "shiftleft/scan"
    }
}
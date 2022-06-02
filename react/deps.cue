package react

import (
    "dagger.io/dagger"

    "universe.dagger.io/x/solomon@dagger.io/yarn"
)

// Install the project dependencies.
#Deps: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
	project: string | *"default"

    // Other actions required to run before this one
    requires: [...string]

    yarn.#Run & {
        "source":   source
        project:    project
        args:       ["install"]
        "requires": requires
    }
}

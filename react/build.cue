package react

import (
    "dagger.io/dagger"
    
    "universe.dagger.io/yarn"
)

// Run yarn test to exceute the react project unit tests.
#Build: {
    // Project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
	project: string | *"default"

    // React static bundle.
    output: _container.output

    _container: yarn.#Build & {
        "source":  source
        "project": project
    }
}

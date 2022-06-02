package react

import (
    "dagger.io/dagger"
    
    "universe.dagger.io/x/solomon@dagger.io/yarn"
)

// Run yarn test to exceute the react project unit tests.
#Build: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
	project: string | *"default"
    
    // Other actions required to run before this one
    requires: [...string]

    yarn.#Run & {
        "source": source
        args:     ["install"]
    }
}

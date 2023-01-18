package react

import (
    "dagger.io/dagger"

    "universe.dagger.io/yarn"
)

// Run yarn test to exceute the react project unit tests.
#Test: {
    // Project source code.
    source: dagger.#FS
        
    // Project name, used for cache scoping.
	project: string | *"default"
    
    // Command return code.
    code: _container.container.export.files."/code"

    _container: yarn.#Script & {
        "source":   source
        "project":  project
        name:       "test"
    }
}

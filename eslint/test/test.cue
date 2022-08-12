package alpine

import (
	"dagger.io/dagger"

    "trustacks.io/eslint"
)

dagger.#Plan & {
    client: filesystem: {
        "./data/app": read: contents: dagger.#FS
    }
	actions: test: {
		// Test: run eslint.
        runEslint: {
            lint: eslint.#Run & {
				source: client.filesystem."./data/app".read.contents
			}
        }
    }
}
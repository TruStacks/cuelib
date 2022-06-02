package alpine

import (
	"dagger.io/dagger"

    "trustacks.io/commitizen"
)

dagger.#Plan & {
    client: filesystem: {
        "./data/src-no-tags":       read: contents: dagger.#FS
        "./data/src-existing-tags": read: contents: dagger.#FS
    }
	actions: test: {
        // Test: get the version for a project with existing tags.
        withTags: {
            version: commitizen.#Version & {
				source: client.filesystem."./data/src-existing-tags".read.contents
			}

			assert: withTags.version.output & "1.0.0"
        }
        
        // Test: get the version for a project with no existing tags.
		withoutTags: {
			version: commitizen.#Version & {
				source: client.filesystem."./data/src-no-tags".read.contents
			}

			assert: withoutTags.version.output & "0.1.0"
		}
    }
}
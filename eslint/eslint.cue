package eslint

import (
    "encoding/json"
    "strings"

    "dagger.io/dagger"
    "dagger.io/dagger/core"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Run the eslint utility.
#Run: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
	project: string | *"default"

    // Use this config if an eslintrc is not present in the source.
    defaultConfig: _ | *{}

    // Other actions required to run before this one
    requires: [...string]

    // The command return code.
	code: container.export.files."/code"

    container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        set -x
        if [ -z "$(ls -al | grep -e '\.*eslintrc.*' || true)" ]; then echo "$ESLINTRC" > .eslintrc; fi
        eslint ./src | tee /logs
        echo $$ > /code
        """#

        export: {
            files: {
                "/code": string
            }
        }

        env: {
            ESLINTRC: json.Marshal(defaultConfig)
            REQUIRES: strings.Join(requires, "_")
        }

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
            "yarnCache": {
				dest:     "/cache/yarn"
				contents: core.#CacheDir & {
					id: "\(project)-yarn"
				}
			}
			"nodeModules": {
				dest:     "/src/node_modules"
				type:     "cache"
				contents: core.#CacheDir & {
					id: "\(project)-nodejs"
				}
			}
        }
    }
}

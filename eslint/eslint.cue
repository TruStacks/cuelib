package eslint

import (
    "encoding/json"

    "dagger.io/dagger"
    "dagger.io/dagger/core"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
    "universe.dagger.io/yarn"
)

// Run the eslint utility.
#Run: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
    project: string | *"default"

    // Use this config if an eslintrc is not present in the source.
    defaultConfig: _ | *{}

    // Command return code.
    code: _container.export.files."/code"

    _container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        if [ -z "$(ls -al | grep -e '\.*eslintrc.*' || true)" ]; then echo "$ESLINTRC" > .eslintrc; fi
        eslint ./src | tee /logs
        echo $$ > /code
        """#

        export: files: "/code": string

        env: ESLINTRC: json.Marshal(defaultConfig)

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
            "installOutput": {
                contents: _install.output
                dest:     "/tmp/yarn_install_output"
            }
        }
    }
    
    _install: yarn.#Install & {
        "source":  source
        "project": project
    }
}

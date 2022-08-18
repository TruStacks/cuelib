package react

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    
    "universe.dagger.io/bash"
)

// Configure the source before executing actions.
#Configure: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping
	project: string | *"default"
    
    // Remote git repository.
    remote: string

    // source private key.
    privateKey: dagger.#Secret

    // Configuration exit code.
	code: _container.export.files."/code"
    
    // The modified source.
    output: _container.export.directories."/_src"
 
    _container: bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"

        script: contents: #"""
        # fetch the source tags
        mkdir ~/.ssh
        echo -e "$PRIVATE_KEY" > ~/.ssh/id_rsa
        
        chmod 600 ~/.ssh/id_rsa
        git remote set-url origin $REMOTE
        GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git fetch --tags

        filters=(
            '.scripts["test"]="CI=true react-scripts test --testResultsProcessor=./node_modules/jest-html-reporter --coverage"'
            '.scripts["build"]="react-scripts build"'
            '.jest={"collectCoverageFrom": ["src/**/*.{js,jsx}"]}'
            '.dependencies["jest-html-reporter"]="latest"'
            '.coverageReporters=["lcov"]'
        )
        for i in ${!filters[@]}; do
            cat package.json | jq "${filters[$i]}" > .package.json.tmp
            cat .package.json.tmp > package.json
        done
        echo $$ > /code
        cp -R /src /_src
        """#

        export: {
            directories: "/_src": dagger.#FS
            files:       "/code": string
        }
        
        env: {
            PRIVATE_KEY: privateKey
            REMOTE:      remote
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

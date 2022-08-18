package commitizen

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Bump to the next semantic release version without committing to 
// the remote git repository.
#Version: {
    // Project source code.
    source: dagger.#FS

    // Command return code.
    code: _container.export.files."/code"

    // Version bumped source.
    output: _container.export.files."/version"
    
    _container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        latest_tag=$(git describe --tag `git rev-list --tags --max-count=1` || true)
        if [ ! -z "$latest_tag" ]; then
            git checkout tags/$latest_tag -- CHANGELOG.md
            git checkout tags/$latest_tag -- .cz.json
        else
            echo '{"commitizen": {"version": "0.0.0"}}' > .cz.json 
        fi
        echo $(cz bump --dry-run --yes | awk '/tag to create:/ {print $4}') | tr -d '\n'  > /version
        cat /version
        echo $$ > /code
        """#

        "mounts": src: {
            dest:     "/src"
            contents: source
        }

        export: files: {
            "/code":    string
            "/version": string
        }
    }
}
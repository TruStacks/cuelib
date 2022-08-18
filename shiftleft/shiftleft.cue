package shiftleft

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Run the shiftleft security scanner.
#Scan: {
    // Project source code.
    source: dagger.#FS

    // Command exit code.
    code: _container.export.files."/code"

    // Shiftleft scan report.
    output: _container.export.directories."/output"

    // Run the yarn install command.
    _container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: """
        scan -m ci -t nodejs,ts,credscan,depscan
        echo $$ > /code
        mkdir /output
        cp -R reports /output
        """

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
        }

        export: {
            directories: "/output": _
            files:       "/code": string
        }
    }
}
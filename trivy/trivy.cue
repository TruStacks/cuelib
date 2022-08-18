package trivy

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

#Scan: {
    // The image tar.
    source: dagger.#FS

    // Configuration exit code.
    code: _container.export.files."/code"

    // Trivy scan report.
    output: _container.export.directories."/output"

    // Run `cz bump` and write the version file.
    _container: bash.#Run & {
        _image: #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        mkdir /output
        trivy image -i /src/image.tar --format template --template "@/contrib/html.tpl" -o /output/report.html
        echo $$ > /code
        """#

        mounts: "image": {
            dest:     "/src"
            contents: source
        }

        export: {
            directories: "/output": _
            files:       "/code": string
        }
    }
}

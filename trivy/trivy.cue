package trivy

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

#Scan: {
    // The image tar.
    image: dagger.#FS

    // Configuration exit code.
    code: container.export.files."/code"

    output: container.export.directories."/output"

    // Run `cz bump` and write the version file.
    container: bash.#Run & {
        _image: #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        set -x
        mkdir /output
        trivy image -i image.tar --format template --template "@/contrib/html.tpl" -o /output/report.html
        echo $$ > /code
        """#

        mounts: "image": {
            dest:     "/src"
            contents: image
        }

        export: {
            directories: "/output": _
            files:       "/code": string
        }
    }
}

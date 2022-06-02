package sops

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

#Encrypt: {
    // The source contents to encrypt.
    source: dagger.#FS

    // The path to the file to encrypt
    path: string

    // The age key used to encrypt the file.
    ageKey: dagger.#Secret

    // Encrypted regex for the sops encrypt command.
    regex: string | *".*"

    // Configuration exit code.
    code: container.export.files."/code"

    // The encrypted sops file.
    output: container.export.files."/output"

    // Run `cz bump` and write the version file.
    container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        set -x
        sops -e --age $AGE_KEY --encrypted-regex $ENCRYPTED_REGEX $FILE_PATH > /output
        echo $$ > /code
        """#

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
        }

        env: {
            AGE_KEY:         ageKey
            FILE_PATH:       path
            ENCRYPTED_REGEX: regex
        }

        export: {
            files: {
                "/code":   string
                "/output": string
            }
        }
    }
}

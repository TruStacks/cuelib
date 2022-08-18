package sops

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

#Encrypt: {
    // Source containg the file to encrypt.
    source: dagger.#FS

    // File to encrypt.
    path: string

    // Encryption key.
    key: string

    // Encrypted regex for the sops encrypt command.
    regex: string | *".*"

    // Configuration exit code.
    code: _container.export.files."/code"

    // Encrypted file output.
    output: _container.export.files."/output"

    // Run `cz bump` and write the version file.
    _container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        sops -e --age $KEY --encrypted-regex $ENCRYPTED_REGEX $FILE_PATH > /output
        echo $$ > /code
        """#

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
        }

        env: {
            KEY:             key
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

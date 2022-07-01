package react

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
)

// Push the commit tag to the remote repository.
#Commit: {
    // Project source code.
    source: dagger.#FS

    // Remote git repository.
    remote: string

    // Secret mounts.
    secrets: dagger.#FS

    // Version tag.
    version: string
    
    // Remote repository url.
    output: configure.export.files."/remote"

    // Configure remote ssh.
    configure: bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"
        
        script: contents: #"""
        mkdir ~/.ssh
        cp /secrets/source-private-key ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        git remote set-url origin $REMOTE
        GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git push --tags

        echo $REMOTE > /remote
        echo $$ > /code
        """#

        env: REMOTE: remote

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
            "secrets": {
                dest:     "/secrets"
                contents: secrets
            }
        }

        export: files: {
            "/remote": string
            "/code":   string
        }
    }

}

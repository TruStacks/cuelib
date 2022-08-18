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

    // source private key.
    privateKey: dagger.#Secret

    // Version tag.
    version: string
    
    // Remote repository url.
    output: _pushTag.export.files."/remote"

    // Configure remote ssh.
    _pushTag: bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"
        
        script: contents: #"""
        mkdir ~/.ssh
        echo -e "$PRIVATE_KEY" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        git remote set-url origin $REMOTE
        GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git push --tags

        echo $REMOTE > /remote
        echo $$ > /code
        """#

        env: {
            REMOTE:      remote
            PRIVATE_KEY: privateKey
        }

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
        }

        export: files: {
            "/remote": string
            "/code":   string
        }
    }
}

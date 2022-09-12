package argocd

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
)

#Login: {
    // Argo CD Server.
    server: string

    // Auth username.
    username: string

    // Auth password.
    password: dagger.#Secret

    // ALlow insecure tls.
    insecure: string | *"false"
    
    // Authenticated Argo CD context.
    output: container.export.directories."/output"

    container: bash.#Run & {
        _image: #Image
        input:  _image.output
        always: true

        script: contents: #"""
        args="--username $USERNAME --password $PASSWORD"

        if [ "$INSECURE" == "true" ]; then args="$args --insecure --plaintext"; fi

        argocd login $SERVER \
            --username $USERNAME \
            --password $PASSWORD \
            --grpc-web \
            $args

        cp -R ~/.config/argocd /output
        """#

        env: {
            SERVER:   server
            USERNAME: username
            PASSWORD: password
            INSECURE: insecure
        }

        export: directories: "/output": dagger.#FS
    }
}
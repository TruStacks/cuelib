package argocd

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash"
)

#Create: {
    server: string
    
    username: string

    password: dagger.#Secret

    project: string

    repo: string

    path: string | *".trustacks/kustomize"

    overlay: string

    privateKey: dagger.#Secret

    revision: string

    destination: string | *"https://kubernetes.default.svc"

    insecure: string | *"false"

    args: [...string]

    login: #Login & {
        "server":   server
        "username": username
        "password": password
        "insecure": insecure
    }

    container: bash.#Run & {
        _image: #Image
        input:  _image.output

        script: contents: #"""
        # copy argocd login context
        mkdir -p ~/.config
        cp -R /argocd ~/.config/argocd

        echo "$PRIVATE_KEY" > /tmp/ssh-private-key
        argocd repo add $REPO --ssh-private-key-path /tmp/ssh-private-key

        if [ "$INSECURE" == "true" ]; then ARGS="$ARGS --insecure --plaintext"; fi
        argocd app create $PROJECT \
            --server $SERVER \
            --repo $REPO \
            --path $REPO_PATH/overlays/$OVERLAY \
            --revision $REVISION \
            --dest-server $DESTINATION \
            --upsert \
            $ARGS

        argocd app sync $PROJECT \
            --server $SERVER \
            $ARGS
        """#

        env: {
            SERVER:      server
            PROJECT:     project
            REPO:        repo
            REPO_PATH:   path
            OVERLAY:     overlay
            REVISION:    revision
            DESTINATION: destination
            PRIVATE_KEY: privateKey
            ARGS:        strings.Join(args, " ")
        }

        mounts: {
            "argocd": {
                dest:     "/argocd"
                contents: login.output
            }
        }
    }
}

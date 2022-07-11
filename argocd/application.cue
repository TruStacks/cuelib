package argocd

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash"
)

#Create: {
    // Argo CD server.
    server: string
    
    // Auth username.
    username: string

    // Auth password.
    password: dagger.#Secret

    // Project name.
    project: string

    // Git repository url.
    repo: string

    // Path to the kustomize deployment assets.
    path: string | *".trustacks/kustomize"

    // Kustomize overlay name.
    overlay: string

    // Git source private key.
    privateKey: dagger.#Secret

    // Git revision name.
    revision: string

    // Destionation kubenretes cluster.
    destination: string | *"https://kubernetes.default.svc"

    // ALlow insecure tls.
    insecure: string | *"false"

    // Argo CD CLI extra arguments.
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

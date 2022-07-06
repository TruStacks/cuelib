package flux2

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
)

#Create: {
    // Project name.
    project: string

    // Source url.
    url: string

    // Source tag.
    tag: string

    // Source ssh private key.
    privateKey: dagger.#Secret

    // Kubernetes configuration file.
    kubeconfig: dagger.#Secret

    bash.#Run & {
        _image: #Image
        input: _image.output

        script: contents: #"""
        mkdir ~/.kube
        echo "$PRIVATE_KEY" > ./private.key
        echo "$KUBECONFIG" > ./kubeconfig
        flux create source git $PROJECT \
            --url=$URL \
            --tag=$TAG \
            --private-key-file=./private.key \
            --fetch-timeout 30s \
            --silent \
            -n workflow-$PROJECT
        """#

        env: {
            PROJECT:     project
            URL:         url
            TAG:         tag
            KUBECONFIG:  kubeconfig
            PRIVATE_KEY: privateKey
        }
    }
}
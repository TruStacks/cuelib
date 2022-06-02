package react

import (
    "strings"

    "dagger.io/dagger"
    
    "universe.dagger.io/bash"
)

// Install the helm chart.
#Helm: {
    // The project source code.
    source: dagger.#FS

    // Project name, used for cache scoping.
	project: string | *"default"
    
    // The kubernetes docker registry secret 
    imagePullSecret: string
    
    // Values to use with helm install.
    helmValues: string
    
    // Other actions required to run before this one.
    requires: [...string]
    
    // The command return code.
	code: container.export.files."/code"
    
    // The version bumped source.
    output: container.export.directories."/output"
    
    container: bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"

        script: contents: #"""
        set -x
        echo "$IMAGE_PULL_SECRET" > .trustacks/helm/templates/image-pull-secret.yaml
        echo "$HELM_VALUES" > .trustacks/helm/values.yaml
        cp -R /src /output
        echo $$ > /code
        """#

        env: {
            REQUIRES:          strings.Join(requires, "_")
            IMAGE_PULL_SECRET: imagePullSecret
            HELM_VALUES:       helmValues
        }

        export: {
            directories: "/output": dagger.#FS
            files:       "/code": string
        }

        mounts: {
            "src": {
                dest:     "/src"
                contents: source
            }
        }
    }
}
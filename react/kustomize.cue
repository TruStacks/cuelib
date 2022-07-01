package react

import (
    "strings"

    "dagger.io/dagger"
    
    "universe.dagger.io/bash"
)

// Prepare the kustomize assets for deployment. 
#Kustomize: {
    // Project source code.
    source: dagger.#FS

    // Build assets
    assets: dagger.#FS

    // Image ref is the.
    imageRef: string

    // registrySecret is used to the pull the application image.
    registrySecret: string

    // Other actions required to run before this one.
    requires: [...string]
    
    // The command return code.
	code: container.export.files."/code"

    // The tagged source.
    output: container.export.directories."/output"
    
    container: bash.#Run & {
        _image:  #Image
        input:   _image.output
        workdir: "/src"

        script: contents: #"""
        set -x
        echo "$REGISTRY_SECRET" > /assets/kustomize/base/registry-secret.yaml
        cd /assets/kustomize/base && kustomize edit set image webserver="$IMAGE_REF"
        
        mkdir -p /src/.trustacks
        cp -R /assets /src/.trustacks/kustomize
        cp -R /src /output
        
        echo $$ > /code
        """#

        env: {
            REQUIRES:        strings.Join(requires, "_")
            IMAGE_REF:       imageRef
            REGISTRY_SECRET: registrySecret
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
            "assets": {
                dest:     "/assets"
                contents: assets
            }
        }
    }
}
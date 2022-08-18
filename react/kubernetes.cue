package react

import (
    "encoding/yaml"
    "strings"

    "dagger.io/dagger"
    
    "universe.dagger.io/bash"
)

// Prepare the kustomize assets for deployment. 
#Kustomize: {
    // Source input.
    input: dagger.#FS

    // Build assets
    assets: dagger.#FS

    // Helm template values.
    values: _

    // registrySecret is used to the pull the application image.
    registrySecret: string

    // Other actions required to run before this one.
    requires: [...string]
    
    // Command return code.
	code: _container.export.files."/code"

    // Tagged source.
    output: _container.export.directories."/output"
    
    _container: bash.#Run & {
        _image:  #Image
        "input": _image.output
        workdir: "/src"

        script: contents: #"""
        # render helm templates
        mkdir /tmp/helm
        cp -R /assets/templates /tmp/helm/templates
        
        cat > /tmp/helm/Chart.yaml <<EOF
        apiVersion: v1
        name: templates
        version: 0
        EOF

        echo "$VALUES" > /tmp/values.yaml
        helm template -f /tmp/values.yaml /tmp/helm --output-dir /tmp/output
        cp /tmp/output/templates/templates/* /assets/kustomize/base

        for template in $(ls /tmp/output/templates/templates/); do
            echo "- $template"  >> /assets/kustomize/base/kustomization.yaml
        done

        # create registry pull secret
        echo "$REGISTRY_SECRET" > /assets/kustomize/base/registry-secret.yaml
        
        mkdir -p /src/.trustacks
        cp -R /assets/kustomize /src/.trustacks/kustomize
        cp -R /src /output
        
        echo $$ > /code
        """#

        env: {
            REQUIRES:        strings.Join(requires, "_")
            REGISTRY_SECRET: registrySecret
            VALUES:          yaml.Marshal(values)
        }

        export: {
            directories: "/output": dagger.#FS
            files:       "/code": string
        }

        mounts: {
            "src": {
                dest:     "/src"
                contents: input
            }
            "assets": {
                dest:     "/assets"
                contents: assets
            }
        }
    }
}
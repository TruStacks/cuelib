package react

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash" 
)

// Gather reports for all analysis actions.
#Analyze: {
    // The list of reports to include in the reports output.
    reports: [name=string]: dagger.#FS

    // Other actions required to run before this onew
    requires: [...string]

    // Command return code.
    code: _container.export.files."/code"

    // Reports bundle.
    output: _container.export.directories."/output"

    _container: bash.#Run & {
        _image: #Image
        input:  _image.output
        script: contents: #"""
        mkdir /output
        cp -R /tmp/reports /output/reports
        echo $$ > /code
        """#

        mounts: {
            for name, contents in reports {
                "\(name)": {
                    dest:       "/tmp/reports/\(name)"
                    "contents": contents
                }
            }
        }

        env: REQUIRES: strings.Join(requires, "_")

        export: {
            directories: "/output": dagger.#FS
            files: {
                "/code": string
            }
        }
    }
}       
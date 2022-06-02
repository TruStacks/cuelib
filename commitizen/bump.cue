package commitizen

import (
    "strings"

    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

// Bump to the next semantic release version and commit to the tag.
#Bump: {
    // The project source code.
    source: dagger.#FS

    // The version bump commit message.
    message: string | *"build: bump $current_version → $new_version [@skip-ci]"

    // Additional files to include in the version bump commit.
    include: [string] | *[]

    // The command return code.
    code: container.export.files."/code"

    // The version bumped source.
    output: container.export.directories."/_src"

    container: bash.#Run & {
        _image:  #Image
        input:   *_image.output | docker.#Image
        workdir: "/src"

        script: contents: #"""
        set -x
        latest_tag=$(git describe --tag `git rev-list --tags --max-count=1` || true)
        if [ ! -z "$latest_tag" ]; then
            git checkout tags/$latest_tag -- CHANGELOG.md
            git checkout tags/$latest_tag -- .cz.json
        else
            cat > .cz.json <<EOF
        {
            "commitizen": {
                "bump_message": "$BUMP_MESSAGE",
                "name": "cz_conventional_commits",
                "tag_format": "\$version",
                "update_changelog_on_bump": true,
                "version": "0.0.0"
            }
        }
        EOF
        fi
        cz bump --yes
        git add $INCLUDE_FILES
        git commit --amend --no-edit
        git tag -f $(cz version -p)
        echo $$ > /code
        cat .cz.json
        cp -R /src /_src
        """#

        "mounts": src: {
            dest:     "/src"
            contents: source
        }

        env: {
            INCLUDE_FILES: strings.Join(include, " ")
            BUMP_MESSAGE:  message
        }

        export: {
            directories: "/_src": _
            files:       "/code": string
        }
    }
}
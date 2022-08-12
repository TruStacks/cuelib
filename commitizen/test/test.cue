package alpine

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"

    "trustacks.io/commitizen"
)

dagger.#Plan & {
    client: filesystem: {
        "./data/src-no-tags":       read: contents: dagger.#FS
        "./data/src-existing-tags": read: contents: dagger.#FS
    }
	actions: test: {
		// Test: get the version for a project with existing tags.
        versionWithTags: {
            version: commitizen.#Version & {
				source: client.filesystem."./data/src-existing-tags".read.contents
			}

			assert: versionWithTags.version.output & "1.0.0"
        }
        
        // Test: get the version for a project with no existing tags.
		versionWithoutTags: {
			version: commitizen.#Version & {
				source: client.filesystem."./data/src-no-tags".read.contents
			}

			assert: versionWithoutTags.version.output & "0.1.0"
		}

        // Test: bump the version for a project with existing tags.
        bumpWithTags: {
            version: commitizen.#Bump & {
				source: client.filesystem."./data/src-existing-tags".read.contents
				amend: ["amend1", "amend2"]
			}

			verify: #AssertFile & {
				input:    bumpWithTags.version.output 
				path:     ".cz.json"
				contents: #"""
				{
				  "commitizen": {
				    "bump_message": "build: bump $current_version > $new_version",
				    "name": "cz_conventional_commits",
				    "tag_format": "$version",
				    "update_changelog_on_bump": true,
				    "version": "1.0.0"
				  }
				}
				"""#
			}
        }
        // Test: bump the version for a project with no existing tags.
		bumpWithoutTags: {
            version: commitizen.#Bump & {
				source:  client.filesystem."./data/src-no-tags".read.contents
				message: "bump message"
			}

			verify: #AssertFile & {
				input:    bumpWithoutTags.version.output 
				path:     ".cz.json"
				contents: #"""
				{
				  "commitizen": {
				    "bump_message": "bump message",
				    "name": "cz_conventional_commits",
				    "tag_format": "$version",
				    "update_changelog_on_bump": true,
				    "version": "0.1.0"
				  }
				}
				"""#
			}
        }
    }
}

#AssertFile: {
	input:    dagger.#FS
	path:     string
	contents: string

	_read: core.#ReadFile & {
		"input": input
		"path":  path
	}

	actual: _read.contents

	// Assertion
	contents: actual
}

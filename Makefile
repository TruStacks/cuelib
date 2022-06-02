.PHONY: init test clean

init:
	@dagger project update
	@curl -Lo ./age_key.txt https://raw.githubusercontent.com/dagger/dagger/main/pkg/universe.dagger.io/age_key.txt
	@curl -Lo ./bats_helpers.bash https://raw.githubusercontent.com/dagger/dagger/main/pkg/universe.dagger.io/bats_helpers.bash
	@npm install --force

test:
	@npm test

clean:
	@cat .gitignore | xargs rm -rf

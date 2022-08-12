setup() {
    load '../../bats_helpers.bash'

    common_setup
}

@test "commitizen" {
    tar xf data/src-existing-tags.tar -C data
    tar xf data/src-no-tags.tar -C data
    dagger "do" -p ./test.cue test
}
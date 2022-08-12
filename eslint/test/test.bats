setup() {
    load '../../bats_helpers.bash'

    common_setup
}

@test "eslint" {
    dagger "do" -p ./test.cue test
}

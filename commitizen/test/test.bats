setup() {
    load '../../bats_helpers.bash'

    common_setup
}

@test "commitizen version" {
    dagger "do" -p ./version.cue test
}

@test "commitizen bump" {
    dagger "do" -p ./bump.cue test
}
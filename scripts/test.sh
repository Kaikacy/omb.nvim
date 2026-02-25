#!/usr/bin/env bash

readonly MINITEST_TAG=v0.17.0

# Clone mini.test repo if not already present
if [[ ! -d .tests ]]; then
    mkdir .tests
    git -c advice.detachedHead=false clone -b "$MINITEST_TAG" --filter=blob:none https://github.com/nvim-mini/mini.test .tests/mini.test
    echo ""
fi

# Run all files if no argument is specified
minitest_cmd="lua MiniTest.run()"
[[ -n $1 ]] && minitest_cmd="lua MiniTest.run_file($1)"

nvim --headless --noplugin -u scripts/minimal_init.lua -c "$minitest_cmd"

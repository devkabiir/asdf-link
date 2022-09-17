#!/usr/bin/env bash
#
# description:
#   Use system tools with asdf version manager
#
# usage:
#   asdf link <tool-name> <version=latest> <...paths=$PWD>"
#
# examples:
#   asdf link zls master ./bin
#   asdf link zls master
#   asdf link zls
#   asdf link rustc nightly ./bin ./Cargo/packages/bin
#
# notes:
#   ---
#

set -e

shopt -s nullglob

function _asdf_link_system_tool_if_not_exists() {
    local tool=$1
    if ! asdf plugin list | grep -q "$tool"; then
        asdf plugin add "$tool" https://github.com/devkabiir/asdf-link
    fi
}

function main() {
    ARGS=("$@")
    tool="${ARGS[0]}"
    version="${ARGS[1]:-latest}"
    source_paths=("${ARGS[@]:2}")

    # default to current directory
    if [ -z "${source_paths// /}" ]; then
        source_paths=("$PWD")
    fi

    _asdf_link_system_tool_if_not_exists "$tool"

    # if the version already exists, we remove it to clear stale shims.
    if asdf list "$tool" "$version" 2>/dev/null | grep -q "$version"; then
        asdf uninstall "$tool" "$version"
    fi
    asdf install "$tool" "$version" 1>/dev/null

    dest_path=$(asdf where "$tool" "$version")/bin/

    echo Creating shims...
    for source_path in "${source_paths[@]}"; do
        ln -sv "$(realpath $source_path)"/* "$dest_path"
    done
    asdf reshim "$tool" "$version"
}

main "$@"

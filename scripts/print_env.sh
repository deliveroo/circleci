#!/usr/bin/env bash

# set -ex

usage() {
  echo 'Expected usage: `print_env $name`. Must be a string at least 1 character in length.' >&2
  exit 1
}

[[ -n "$1" ]] || usage

(set -o posix; set) | while read -r line; do
  case "$line" in
    ${1}_*) echo export ${line#"${1}_"};;
  esac
done

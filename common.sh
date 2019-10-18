#!/usr/bin/env bash

set -eu

require_tool() {
  if ! command -v "${1}" > /dev/null
  then
    echo "Missing required tool: ${1}"
    exit 2
  fi
}

require_tools() {
  while (( "${#}" ))
  do
    require_tool "${1}"
    shift
  done
}

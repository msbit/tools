#!/usr/bin/env bash

set -o errexit
set -o nounset

WORKING_DIR=$(mktemp -d -t scratch.XXXXXXXXXX)

pushd "${WORKING_DIR}"
PS1="\h:\W \u [$(basename "${WORKING_DIR}")]\$ " HOME=${WORKING_DIR} bash --norc
popd
rm -rf "${WORKING_DIR}"

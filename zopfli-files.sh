#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -lt 1 ]
then
  echo "Usage ${0} <file> [<file> ...]"
  exit 1
fi

require_tools zopflipng

while (( "${#}" ))
do
  OUTPUTFILE=$(mktemp)

  zopflipng -m -y "${1}" "${OUTPUTFILE}"

  mv "${OUTPUTFILE}" "${1}"

  shift
done

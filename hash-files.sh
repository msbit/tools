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

require_tools md5sum stat

while (( "${#}" ))
do
  MD5SUM=$(md5sum "${1}"  | awk '{print $1}')
  STAT=$(stat -c "%Y" "${1}")
  EXTENSION=${1#*.}

  NAME="${STAT}-${MD5SUM}.${EXTENSION}"

  mv "${1}" "${NAME}"

  shift
done

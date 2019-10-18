#!/usr/bin/env bash

set -eu

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -ne 1 ]
then
  echo "Usage ${0} <pkg-id>"
  exit 1
fi

require_tools pkgutil

pkgutil --pkg-info "${1}"

VOLUME=$(pkgutil --pkg-info "${1}" | grep '^volume' | awk '{print $2}')
LOCATION=$(pkgutil --pkg-info "${1}" | grep '^location' | awk '{print $2}')

BASE_PATH="${VOLUME}/${LOCATION}"

echo "Removing files"
pkgutil --files "${1}" | awk '{print length(), $0}' | sort -rn | while read -r _ FILE
do
  FULL_PATH="${BASE_PATH}/${FILE}"
  sudo rm -d "${FULL_PATH}" || echo "Skipping ${FULL_PATH}"
done

sudo rm -d "${BASE_PATH}" || echo "Skipping ${BASE_PATH}"

sudo pkgutil --forget "${1}"

#!/usr/bin/env bash

set -eu

if [ ${#} -ne 1 ]
then
  echo "Usage ${0} <pkg-id>"
  exit 1
fi

if ! command -v pkgutil > /dev/null
then
  echo "Missing required tool: pkgutil"
  exit 1
fi

pkgutil --pkg-info "${1}"

VOLUME=$(pkgutil --pkg-info "${1}" | grep '^volume' | awk '{print $2}')
LOCATION=$(pkgutil --pkg-info "${1}" | grep '^location' | awk '{print $2}')

BASE_PATH="${VOLUME}/${LOCATION}"

echo "Removing files"
pkgutil --files "${1}" | while read -r FILE
do
  FULL_PATH="${BASE_PATH}/${FILE}"
  if [ -f "${FULL_PATH}" ]
  then
    sudo rm "${FULL_PATH}"
  fi
done

echo "Removing directories"
pkgutil --files "${1}" | while read -r FILE
do
  FULL_PATH="${BASE_PATH}/${FILE}"
  if [ -d "${FULL_PATH}" ]
  then
    sudo rm -r "${FULL_PATH}"
  fi
done

sudo rm -rf "${BASE_PATH}"

sudo pkgutil --forget "${1}"

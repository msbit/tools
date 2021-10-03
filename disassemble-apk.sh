#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ "${#}" -ne "2" ]
then
  echo "Usage ${0} <apk-file> <dest-dir>"
  exit 1
fi

APKFILE="$(realpath "${1}")"
DEST="${2}"

require_tools baksmali

mkdir -p "${DEST}"

pushd "${DEST}"

unzip "${APKFILE}" '*.dex'

for DEXFILE in *.dex
do
  baksmali disassemble \
    --output "${DEXFILE%.dex}" \
    --use-locals \
    "${DEXFILE}"
  rm "${DEXFILE}"
done

popd

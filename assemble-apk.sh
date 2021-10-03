#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ "${#}" -ne "2" ]
then
  echo "Usage ${0} <source-dir> <apk-file>"
  exit 1
fi

SOURCE="${1}"
APKFILE="$(realpath "${2}")"

require_tools smali zip

pushd "${SOURCE}"

for CLASSDIR in classes*
do
  smali assemble --output "${CLASSDIR}.dex" "${CLASSDIR}"
  zip "${APKFILE}" "${CLASSDIR}.dex"
  rm "${CLASSDIR}.dex"
done

popd

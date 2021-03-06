#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -lt 1 ]
then
  echo "Usage ${0} <apk-file> [<apk-file> ...]"
  exit 1
fi

require_tools apktool

while [ ${#} -gt 0 ]
do
  APK_FILE=${1}

  WORKING_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

  apktool d --force --no-src --output "${WORKING_DIR}" --quiet "${APK_FILE}"

  VERSION_CODE=$(grep versionCode: "${WORKING_DIR}/apktool.yml" | sed -e "s/^.*versionCode: '\([^']*\)'.*$/\1/g")
  VERSION_NAME=$(grep versionName: "${WORKING_DIR}/apktool.yml" | sed -e 's/^.*versionName: \(.*\)$/\1/g')
  PACKAGE=$(grep package= "${WORKING_DIR}/AndroidManifest.xml" | sed -e 's/^.*package="\([^"]*\)".*$/\1/g')

  echo "${PACKAGE}" "${VERSION_CODE}" "${VERSION_NAME}"

  rm -rf "${WORKING_DIR}"
  shift
done

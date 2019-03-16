#!/usr/bin/env bash

set -eu

if [ ${#} -lt 1 ] 
then
  echo "Usage ${0} <apk-file> [<apk-file> ...]"
  exit 1
fi

if ! which apktool > /dev/null
then
  echo "Missing required tool: apktool"
  exit 1
fi

while [ ${#} -gt 0 ]
do
  APK_FILE=${1}

  WORKING_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

  apktool d -f "${APK_FILE}" "${WORKING_DIR}" > /dev/null 2>&1

  VERSION_CODE=$(grep android:versionCode= "${WORKING_DIR}/AndroidManifest.xml" | sed -e 's/^.*android:versionCode="\([^"]*\)".*$/\1/g')
  VERSION_NAME=$(grep android:versionName= "${WORKING_DIR}/AndroidManifest.xml" | sed -e 's/^.*android:versionName="\([^"]*\)".*$/\1/g')
  PACKAGE=$(grep package= "${WORKING_DIR}/AndroidManifest.xml" | sed -e 's/^.*package="\([^"]*\)".*$/\1/g')

  echo "${PACKAGE}" "${VERSION_CODE}" "${VERSION_NAME}"

  rm -rf "${WORKING_DIR}"
  shift
done

#!/usr/bin/env bash

set -eu

if [ ${#} -ne 2 ]
then
  echo "Usage ${0} <url> <quality>"
  exit 1
fi

if ! which curl > /dev/null
then
  echo "Missing required tool: curl"
  exit 1
fi

if ! which ffmpeg > /dev/null
then
  echo "Missing required tool: ffmpeg"
  exit 1
fi

SOURCE_PATH=$(pwd)

MASTER_URL=${1}
QUALITY=${2}

MASTER_FILE=$(mktemp -t $$.XXXXXXXXXX)
CHILD_FILE=$(mktemp -t $$.XXXXXXXXXX)
CONCAT_FILE=$(mktemp -t $$.XXXXXXXXXX)
CHILD_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

CURL_OPTS="--retry 4 -s -S"

curl ${CURL_OPTS} -o "${MASTER_FILE}" "${MASTER_URL}"

CHILD_URL=$(grep "${QUALITY}_vod.m3u8" "${MASTER_FILE}")
VOD_PART_BASE="${CHILD_URL%%${QUALITY}_vod.m3u8}"

curl ${CURL_OPTS} -o "${CHILD_FILE}" "${CHILD_URL}"

pushd "${CHILD_DIR}"

grep "^${QUALITY}_vod_.*ts$" "${CHILD_FILE}" | while read -r VOD_PART_FILE
do
  echo "file '${CHILD_DIR}/${VOD_PART_FILE}'" >> "${CONCAT_FILE}"
  curl ${CURL_OPTS} -O --retry 4 "${VOD_PART_BASE}${VOD_PART_FILE}"
  echo -n '.'
done
echo

ffmpeg -f concat -safe 0 -i "${CONCAT_FILE}" -c copy "${SOURCE_PATH}/${QUALITY}_vod.ts"

rm -rf "${CHILD_DIR}"
rm "${CHILD_FILE}"
rm "${MASTER_FILE}"

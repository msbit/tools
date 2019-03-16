#!/usr/bin/env bash

if [ ! ${#} -eq 2 ]
then
  echo "Usage ${0} <url> <quality>"
  exit 1
fi

SOURCE_PATH=$(pwd)

MASTER_URL=${1}
QUALITY=${2}

MASTER_FILE=$(mktemp -t $$)
CHILD_FILE=$(mktemp -t $$)
CONCAT_FILE=$(mktemp -t $$)
CHILD_DIR=$(mktemp -d -t $$)

curl -s -o "${MASTER_FILE}" "${MASTER_URL}"

CHILD_URL=$(grep "${QUALITY}_vod.m3u8" "${MASTER_FILE}")
VOD_PART_BASE=$(echo "${CHILD_URL}" | sed -e "s/${QUALITY}_vod.m3u8$//g")

curl -s -o "${CHILD_FILE}" "${CHILD_URL}"

pushd "${CHILD_DIR}"


grep "^${QUALITY}_vod_.*ts$" "${CHILD_FILE}" | while read VOD_PART_FILE
do
  echo "file '${CHILD_DIR}/${VOD_PART_FILE}'" >> "${CONCAT_FILE}"
  curl -s -O "${VOD_PART_BASE}${VOD_PART_FILE}"
  echo -n '.'
done
echo

ffmpeg -f concat -i "${CONCAT_FILE}" -c copy "${SOURCE_PATH}/${QUALITY}_vod.ts"

rm -rf "${CHILD_DIR}"
rm "${CHILD_FILE}"
rm "${MASTER_FILE}"

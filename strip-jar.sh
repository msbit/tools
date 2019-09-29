#!/usr/bin/env bash

set -eu

if [ ${#} -ne 3 ]
then
  echo "Usage ${0} <in-jar-file> <out-jar-file> <class>"
  exit 1
fi

if ! command -v jar > /dev/null
then
  echo "Missing required tool: jar"
  exit 2
fi

if ! command -v unzip > /dev/null
then
  echo "Missing required tool: unzip"
  exit 2
fi

INPUT_JAR_FILE=${1}
OUTPUT_JAR_FILE=${2}
STRIP_PATH=${3}

UNZIP_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

unzip "${INPUT_JAR_FILE}" -d "${UNZIP_DIR}"

find "${UNZIP_DIR}" -regex "${UNZIP_DIR}/${STRIP_PATH}.*\.class$" -delete

jar cvf "${OUTPUT_JAR_FILE}" -C "${UNZIP_DIR}" .

rm -r "${UNZIP_DIR}"

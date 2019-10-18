#!/usr/bin/env bash

set -eu

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -ne 3 ]
then
  echo "Usage ${0} <in-jar-file> <out-jar-file> <class>"
  exit 1
fi

require_tools jar unzip

INPUT_JAR_FILE=${1}
OUTPUT_JAR_FILE=${2}
STRIP_PATH=${3}

UNZIP_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

unzip "${INPUT_JAR_FILE}" -d "${UNZIP_DIR}"

find "${UNZIP_DIR}" -regex "${UNZIP_DIR}/${STRIP_PATH}.*\.class$" -delete

jar cvf "${OUTPUT_JAR_FILE}" -C "${UNZIP_DIR}" .

rm -r "${UNZIP_DIR}"

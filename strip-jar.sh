#!/usr/bin/env bash

set -eu

if [ ${#} -ne 3 ]
then
  echo "Usage ${0} <in-jar-file> <out-jar-file> <class>"
  exit 1
fi

if ! command -v unzip > /dev/null
then
  echo "Missing required tool: unzip"
  exit 3
fi

if ! command -v jar > /dev/null
then
  echo "Missing required tool: jar"
  exit 3
fi

UNZIP_DIR=$(mktemp -d -t $$.XXXXXXXXXX)

unzip "${1}" -d "${UNZIP_DIR}"

find "${UNZIP_DIR}" -regex "${UNZIP_DIR}/${3}.*\.class$" -delete

jar cvf "${2}" -C "${UNZIP_DIR}" .

rm -r "${UNZIP_DIR}"

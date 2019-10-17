#!/usr/bin/env bash

set -eu

if [ ${#} -lt 1 ]
then
  echo "Usage ${0} <file> [<file> ...]"
  exit 1
fi

if ! command -v md5sum > /dev/null
then
  echo "Missing required tool: md5sum"
  exit 2
fi

if ! command -v stat > /dev/null
then
  echo "Missing required tool: stat"
  exit 2
fi

while (( "${#}" ))
do
  MD5SUM=$(md5sum "${1}"  | awk '{print $1}')
  STAT=$(stat -c "%Y" "${1}")
  EXTENSION=${1#*.}

  NAME="${STAT}-${MD5SUM}.${EXTENSION}"

  mv "${1}" "${NAME}"

  shift
done

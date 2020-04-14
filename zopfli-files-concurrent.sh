#!/usr/bin/env bash

set -eux

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -lt 1 ] 
then
  echo "Usage ${0} <file> [<file> ...]"
  exit 1
fi

require_tools nproc zopflipng

COUNT=0

while (( "${#}" ))
do
  COUNT=$((COUNT + 1))
  OUTPUTFILE=$(mktemp)

  (zopflipng -m -y "${1}" "${OUTPUTFILE}" && mv "${OUTPUTFILE}" "${1}") &

  if [ $((COUNT % $(nproc))) -eq 0 ]
  then
    wait
  fi

  shift
done

wait

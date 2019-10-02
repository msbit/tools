#!/usr/bin/env bash

set -eu

if [ ${#} -eq 0 ]
then
  echo "Usage ${0} <curl-arguments>"
  exit 1
fi

if ! command -v curl > /dev/null
then
  echo "Missing required tool: curl"
  exit 2
fi

for _ in $(seq 1 5)
do
  curl "${@}" \
    --output /dev/null \
    --silent \
    --write-out 'time_total:  %{time_total}\n'
done

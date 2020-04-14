#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -eq 0 ]
then
  echo "Usage ${0} <curl-arguments>"
  exit 1
fi

require_tools curl

for _ in $(seq 1 5)
do
  curl "${@}" \
    --output /dev/null \
    --silent \
    --write-out 'time_total:  %{time_total}\n'
done

#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -eq 0 ]
then
  echo "Usage ${0} <push-arguments>"
  exit 1
fi

require_tools git

git remote | while read -r REMOTE
do
  git push "${REMOTE}" ${@}
done

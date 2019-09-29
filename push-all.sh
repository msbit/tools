#!/usr/bin/env bash

set -eu

if [ ${#} -eq 0 ]
then
  echo "Usage ${0} <push-arguments>"
  exit 1
fi

if ! command -v git > /dev/null
then
  echo "Missing required tool: git"
  exit 2
fi

git remote | while read -r REMOTE
do
  git push "${REMOTE}" ${@}
done

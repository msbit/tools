#!/usr/bin/env bash

set -eu

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

require_tools bundle git

GIT_MESSAGE_FILE=$(mktemp)
GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_UPDATES_BRANCH=bundle-updates-$(date +%s)
DIRECT=()
TRANSITIVE=()

git checkout -b "${GIT_UPDATES_BRANCH}"

bundle update

MODIFIED_GEM_VERS=$(git diff Gemfile.lock | grep '^+    [^ ]' || echo -n)

if [ "${MODIFIED_GEM_VERS}" == '' ]
then
  git checkout "${GIT_CURRENT_BRANCH}"
  git branch -D "${GIT_UPDATES_BRANCH}"
else
  while read -r _ GEM VER
  do
    grep --silent "^  gem '${GEM}'" Gemfile && DIRECT+=("${GEM}@${VER}") || TRANSITIVE+=("${GEM}@${VER}")
  done <<< "${MODIFIED_GEM_VERS}"

  echo "Dependency updates" >> "${GIT_MESSAGE_FILE}"
  echo >> "${GIT_MESSAGE_FILE}"

  if [[ "${#DIRECT[@]}" -gt 0 ]]
  then
    echo "Direct dependencies:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"
    for GEM_VER in "${DIRECT[@]}"
    do
      echo "  * ${GEM_VER//@/ }" >> "${GIT_MESSAGE_FILE}"
    done
    echo >> "${GIT_MESSAGE_FILE}"
  fi

  if [[ "${#TRANSITIVE[@]}" -gt 0 ]]
  then
    echo "Transitive dependencies:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"
    for GEM_VER in "${TRANSITIVE[@]}"
    do
      echo "  * ${GEM_VER//@/ }" >> "${GIT_MESSAGE_FILE}"
    done
  fi

  git add Gemfile Gemfile.lock
  git commit --file="${GIT_MESSAGE_FILE}"
fi

rm "${GIT_MESSAGE_FILE}"

#!/usr/bin/env bash

set -eu

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

require_tools composer git

COMPOSER_ACTIONS_FILE=$(mktemp)
GIT_MESSAGE_FILE=$(mktemp)
GIT_CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_UPDATES_BRANCH=composer-updates-$(date +%s)
DIRECT=()
TRANSITIVE=()

cleanup() {
  remove_updates_branch
  remove_temporary_files
}

remove_updates_branch() {
  git checkout "${GIT_CURRENT_BRANCH}"
  git branch -D "${GIT_UPDATES_BRANCH}"
}

remove_temporary_files() {
  rm -f "${COMPOSER_ACTIONS_FILE}"
  rm -f "${GIT_MESSAGE_FILE}"
}

process_dependencies() {
  DOWNGRADE=()
  INSTALL=()
  REMOVE=()
  UPDATE=()

  DEPENDENCIES=("$@")

  for ((i = 0; i < ${#DEPENDENCIES[@]}; i++))
  do
    read -r ACTION DEPENDENCY VERSION <<< ${DEPENDENCIES[$i]}

    if [ "${ACTION}" == 'Downgrading' ]
    then
      DOWNGRADE+=("${DEPENDENCY} ${VERSION}")
    fi

    if [ "${ACTION}" == 'Installing' ]
    then
      INSTALL+=("${DEPENDENCY} ${VERSION}")
    fi

    if [ "${ACTION}" == 'Removing' ]
    then
      REMOVE+=("${DEPENDENCY} ${VERSION}")
    fi

    if [ "${ACTION}" == 'Updating' ]
    then
      UPDATE+=("${DEPENDENCY} ${VERSION}")
    fi
  done

  if [[ "${#DOWNGRADE[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "  Downgraded:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"

    for ((i = 0; i < ${#DOWNGRADE[@]}; i++))
    do
      echo "  * ${DOWNGRADE[$i]}"  >> "${GIT_MESSAGE_FILE}"
    done
  fi

  if [[ "${#INSTALL[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "  Installed:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"

    for ((i = 0; i < ${#INSTALL[@]}; i++))
    do
      echo "  * ${INSTALL[$i]}"  >> "${GIT_MESSAGE_FILE}"
    done
  fi

  if [[ "${#REMOVE[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "  Removed:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"

    for ((i = 0; i < ${#REMOVE[@]}; i++))
    do
      echo "  * ${REMOVE[$i]}"  >> "${GIT_MESSAGE_FILE}"
    done
  fi

  if [[ "${#UPDATE[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "  Updated:" >> "${GIT_MESSAGE_FILE}"
    echo >> "${GIT_MESSAGE_FILE}"

    for ((i = 0; i < ${#UPDATE[@]}; i++))
    do
      echo "  * ${UPDATE[$i]}"  >> "${GIT_MESSAGE_FILE}"
    done
 fi
}

trap 'cleanup' ERR

git checkout -b "${GIT_UPDATES_BRANCH}"

rm -r vendor

composer install

composer update > "${COMPOSER_ACTIONS_FILE}" 2>&1

COMPOSER_ACTIONS=$(grep '^  - ' "${COMPOSER_ACTIONS_FILE}" | sort)

if [ "${COMPOSER_ACTIONS}" == '' ]
then
  cleanup
else
  while read -r _ ACTION DEPENDENCY REST
  do
    VERSION=$(echo "${REST}" | sed -e 's/).*$/)/g')
    grep --silent "\"${DEPENDENCY}\"" composer.json && DIRECT+=("${ACTION} ${DEPENDENCY} ${VERSION}") || TRANSITIVE+=("${ACTION} ${DEPENDENCY} ${VERSION}")
  done <<< "${COMPOSER_ACTIONS}"

  echo "Dependency updates" >> "${GIT_MESSAGE_FILE}"

  if [[ "${#DIRECT[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "Direct dependencies:" >> "${GIT_MESSAGE_FILE}"

    process_dependencies "${DIRECT[@]}"
  fi

  if [[ "${#TRANSITIVE[@]}" -gt 0 ]]
  then
    echo >> "${GIT_MESSAGE_FILE}"
    echo "Transitive dependencies:" >> "${GIT_MESSAGE_FILE}"

    process_dependencies "${TRANSITIVE[@]}"
  fi

  git add composer.json composer.lock
  git commit --file="${GIT_MESSAGE_FILE}"
fi

remove_temporary_files

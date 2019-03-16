#!/usr/bin/env bash

set -eu

if ! which drush > /dev/null
then
  echo "Missing required tool: drush" 
  exit 1
fi

drush ard
drush up drupal
drush up --security-only
drush up

#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

require_tools drush

drush ard
drush up drupal
drush up --security-only
drush up

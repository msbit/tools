#!/usr/bin/env bash

set -eu

drush ard
drush up drupal
drush up --security-only
drush up

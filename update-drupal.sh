#!/usr/bin/env bash

drush ard
drush up drupal
drush up --security-only
drush up

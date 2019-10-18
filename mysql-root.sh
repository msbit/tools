#!/usr/bin/env bash

set -eu

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

require_tools mysql

MYSQL_USER=debian-sys-maint
MYSQL_PASSWORD=$(grep password /etc/mysql/debian.cnf | sort | uniq | awk '{print $3}')

mysql --user=${MYSQL_USER} --password="${MYSQL_PASSWORD}"

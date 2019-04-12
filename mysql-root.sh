#!/usr/bin/env bash

set -eu

if ! command -v mysql > /dev/null
then
  echo "Missing required tool: mysql"
  exit 1
fi

MYSQL_USER=debian-sys-maint
MYSQL_PASSWORD=$(grep password /etc/mysql/debian.cnf | sort | uniq | awk '{print $3}')

mysql --user=${MYSQL_USER} --password="${MYSQL_PASSWORD}"

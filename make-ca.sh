#!/usr/bin/env bash

set -eu

if [ ${#} != 4 ]
then
  echo "Usage: ${0} <ca-root-dir> <ca-cn> <server-cn> <client-cn>"
  exit 1
fi 

CA_ROOT=${1}
CA_CN=${2}
SERVER_CN=${3}
CLIENT_CN=${4}
DEFAULT_C='AU'
DEFAULT_ST='Victoria'
DEFAULT_L='Melbourne'
DEFAULT_O='University of Melbourne'
DEFAULT_OU='Faculty of Science'
DEFAULT_SUBJ="/C=${DEFAULT_C}/ST=${DEFAULT_ST}/L=${DEFAULT_L}/O=${DEFAULT_O}/OU=${DEFAULT_OU}"

if [ ! -e "${CA_ROOT}/certificate-authority.key" ]
then
    mkdir -p "${CA_ROOT}"
    openssl genrsa -out "${CA_ROOT}/certificate-authority.key" 2048

    openssl req -new \
        -x509 \
        -nodes \
        -days 1000 \
        -key "${CA_ROOT}/certificate-authority.key" \
        -out "${CA_ROOT}/certificate-authority.crt" \
        -subj "${DEFAULT_SUBJ}/CN=${CA_CN}"
fi

openssl req -newkey rsa:2048 \
    -days 1000 \
    -nodes \
    -keyout "${CA_ROOT}/${SERVER_CN}.key" \
    -out "${CA_ROOT}/${SERVER_CN}.csr" \
    -subj "${DEFAULT_SUBJ}/CN=${SERVER_CN}"

openssl x509 -req \
    -in "${CA_ROOT}/${SERVER_CN}.csr" \
    -days 1000 \
    -CA "${CA_ROOT}/certificate-authority.crt" \
    -CAkey "${CA_ROOT}/certificate-authority.key" \
    -set_serial 01 \
    -out "${CA_ROOT}/${SERVER_CN}.crt"

openssl req -newkey rsa:2048 \
    -days 1000 \
    -nodes \
    -keyout "${CA_ROOT}/${CLIENT_CN}.key" \
    -out "${CA_ROOT}/${CLIENT_CN}.csr" \
    -subj "${DEFAULT_SUBJ}/CN=${CLIENT_CN}"

openssl x509 -req \
    -in "${CA_ROOT}/${CLIENT_CN}.csr" \
    -days 1000 \
    -CA "${CA_ROOT}/certificate-authority.crt" \
    -CAkey "${CA_ROOT}/certificate-authority.key" \
    -set_serial 01 \
    -out "${CA_ROOT}/${CLIENT_CN}.crt"

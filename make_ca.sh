#!/bin/bash

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
    -keyout ${SERVER_CN}.key \
    -out ${SERVER_CN}.csr \
    -subj "${DEFAULT_SUBJ}/CN=${SERVER_CN}"

openssl x509 -req \
    -in ${SERVER_CN}.csr \
    -days 1000 \
    -CA "${CA_ROOT}/certificate-authority.crt" \
    -CAkey "${CA_ROOT}/certificate-authority.key" \
    -set_serial 01 \
    -out ${SERVER_CN}.crt

openssl req -newkey rsa:2048 \
    -days 1000 \
    -nodes \
    -keyout ${CLIENT_CN}.key \
    -out ${CLIENT_CN}.csr \
    -subj "${DEFAULT_SUBJ}/CN=${CLIENT_CN}"

openssl x509 -req \
    -in ${CLIENT_CN}.csr \
    -days 1000 \
    -CA "${CA_ROOT}/certificate-authority.crt" \
    -CAkey "${CA_ROOT}/certificate-authority.key" \
    -set_serial 01 \
    -out ${CLIENT_CN}.crt

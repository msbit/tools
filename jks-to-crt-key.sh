#!/usr/bin/env bash

set -eu

if [ ${#} -ne 2 ]
then
  echo "Usage ${0} <source-key-store> <source-alias>"
  exit 1
fi

if ! command -v keytool > /dev/null
then
  echo "Missing required tool: keytool"
  exit 2
fi

if ! command -v openssl > /dev/null
then
  echo "Missing required tool: openssl"
  exit 2
fi

SRCKEYSTORE=${1}
SRCALIAS=${2}

echo -n 'Enter input keystore key (same for keystore and key): '
read -r SRCKEYSTOREPASS

DSTKEYSTORE=$(mktemp)
DSTKEYSTOREPASS=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | md5sum | awk '{print $1}')

rm "${DSTKEYSTORE}"

keytool -importkeystore \
	-srckeystore "${SRCKEYSTORE}" \
	-srcstoretype JKS \
	-srcstorepass "${SRCKEYSTOREPASS}" \
	-srcalias "${SRCALIAS}" \
	-destkeystore "${DSTKEYSTORE}" \
	-deststoretype PKCS12 \
	-deststorepass "${DSTKEYSTOREPASS}" \
	-destkeypass "${DSTKEYSTOREPASS}"

openssl pkcs12 -in "${DSTKEYSTORE}" \
	-nocerts \
	-nodes \
	-passin "pass:${DSTKEYSTOREPASS}" \
	-out "${SRCALIAS}-private.key"
openssl pkcs12 -in "${DSTKEYSTORE}" \
	-clcerts \
	-nokeys \
	-nodes \
	-passin "pass:${DSTKEYSTOREPASS}" \
	-out "${SRCALIAS}-public.crt"

rm "${DSTKEYSTORE}"

echo "Public certificate at: ${SRCALIAS}-public.crt"
echo "Private key at: ${SRCALIAS}-private.key"

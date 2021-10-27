#!/usr/bin/env bash

set -o errexit
set -o nounset

# shellcheck source=common.sh
source "$(dirname "${0}")/common.sh"

if [ ${#} -ne 2 ] 
then
  echo "Usage ${0} <bae64-modulus> <base64-exponent>"
  exit 1
fi

require_tools base64 openssl xxd

MODULUS=${1}
EXPONENT=${2}

HEX_MODULUS=$(echo "${MODULUS}" | base64 -d | xxd -p -c 256)
HEX_EXPONENT=$(echo "${EXPONENT}" | base64 -d | xxd -p -c 256)

openssl asn1parse -genconf <(
cat <<END
  asn1=SEQUENCE:pubkeyinfo
  [pubkeyinfo]
  algorithm=SEQUENCE:rsa_alg
  pubkey=BITWRAP,SEQUENCE:rsapubkey
  [rsa_alg]
  algorithm=OID:rsaEncryption
  parameter=NULL
  [rsapubkey] 
  n=INTEGER:0x${HEX_MODULUS}
  e=INTEGER:0x${HEX_EXPONENT}
END
) -out pubkey.der -noout
openssl rsa -in pubkey.der -inform der -pubin -out pubkey.pem
rm pubkey.der

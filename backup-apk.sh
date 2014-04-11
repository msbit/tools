#!/bin/bash

if [ ${#} -eq 0 ]
then
  echo "Usage ${0} <destination-dir>"
  exit 1
fi

TMP_DIR=$(mktemp -d -t backup-apk)
if [[ "${1}" = /* || "${1}" = ~* ]]
then
  DEST_DIR=${1}
else
  DEST_DIR=$(pwd)/${1}
fi

LOG_FILE=${DEST_DIR}/.backup-apk

touch ${LOG_FILE}

mkdir -p ${DEST_DIR}

cd ${TMP_DIR}

adb shell pm list packages -f | sed -e 's/^package://g' -e 's/=/ /g' -e 's///g' | sort | while read PKG_FILE PKG_NAME
do
  DEVICE_MD5="$(adb shell md5 ${PKG_FILE} | awk '{print $1}')"
  if grep -q "${DEVICE_MD5}:${PKG_NAME}" ${LOG_FILE}
  then
    echo "Skipping ${PKG_NAME}"
    continue
  fi
  adb pull ${PKG_FILE} ${PKG_NAME}
  if [[ ! -s "${PKG_NAME}" ]] 
  then
    echo "Error fetching ${PKG_NAME}"
    continue
  fi
  MD5=$(md5 -q ${PKG_NAME})
  mv ${PKG_NAME} ${DEST_DIR}/${PKG_NAME}.${MD5}.apk
  echo "Copied ${PKG_NAME}"
  echo ${DEVICE_MD5}:${PKG_NAME} >> ${LOG_FILE}
done

rm -rf ${TMP_DIR}

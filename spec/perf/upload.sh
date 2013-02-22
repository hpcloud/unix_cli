#!/bin/bash -e
if [ $# -ne 2 ]
then
  echo "Usage: ${0} <file> <md5sum>" >&1
  exit 1
fi
FILE="${1}"
MD5SUM="${2}"
CONTAINER=":perfup"
hpcloud remove -f ${CONTAINER} >/dev/null 2>/dev/null || true
hpcloud containers:add ${CONTAINER} >/dev/null

/usr/bin/time --format "%e" hpcloud copy ${FILE} ${CONTAINER} 2>&1 >/dev/null

BASE=$(basename ${FILE})
RESULT=$(hpcloud list ${CONTAINER}/${BASE} -c etag)
if [ ${RESULT} != ${MD5SUM} ]
then
  echo "MD5 sum ${FILE} mismatch ${RESULT} not equal ${MD5SUM}" >&1
  exit 1
fi
hpcloud remove -f ${CONTAINER} >/dev/null
exit 0

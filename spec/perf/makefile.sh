#!/bin/bash -e
if [ $# -ne 2 ]
then
  echo "Usage: ${0} <file> <size>" >&1
  exit 1
fi
FILE="${1}"
SIZE="${2}"

if [ ! -f "${FILE}" ]
then
  dd if=/dev/urandom of="${FILE}" ibs=1024 count=${SIZE} >/dev/null 2>/dev/null || exit 1
fi
md5sum -b "${FILE}" | cut -f1 -d' '
exit 0

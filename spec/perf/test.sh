#!/bin/bash -e
if [ $# -ne 1 ]
then
  echo "Usage: ${0} <size>" >&1
  exit 1
fi
SIZE="${1}"
FILE="spec/tmp/${SIZE}"

MD5SUM=$(./spec/perf/makefile.sh ${FILE} ${SIZE})
./spec/perf/upload.sh ${FILE} ${MD5SUM}

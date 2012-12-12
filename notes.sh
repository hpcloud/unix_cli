#!/bin/bash
#
# Build the release notes page
#
COLUMNS=256;
LINES=24;
export COLUMNS LINES;
NOTES=notes.txt
DATE=$(date +'%D')
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`

function toc { sed -e 's/^##Release \(.*\) Features##/##Release \1 Features## {\1}/' -e 's/Features## {\([^.]*\).\([^.]*\).\([^.]*\)}/Features## {#v\1_\2_\3}/' CHANGELOG; }

echo "These are the release notes for the HP Cloud services UNIX CLI.  The current release number for the [UNIX CLI software](/cli/unix) is version ${VERSION}, released on ${DATE}." >${NOTES}
echo >>${NOTES}
toc | grep '##Release' | sed -e 's/^##/* [/' -e 's/## /]/' -e 's/{/(/' -e 's/\}/)/' >>${NOTES}
echo >>${NOTES}
toc >>${NOTES}

CONTAINER="documentation-downloads"
DEST=":${CONTAINER}/unixcli/"
cat ${NOTES}
hpcloud copy -a deploy ${NOTES} $DEST
hpcloud location -a deploy ${DEST}${NOTES}

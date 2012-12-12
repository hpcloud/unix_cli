#!/bin/bash -ex
SRC=`pwd`
TMP=/tmp/unix_cli_drupal
NOTESMD='Release-Notes-for-the-HP-Cloud-Services-UNIX-CLI.md'
REFERENCEMD='UNIX-CLI-Command-Line-Reference.md'
NOTES=${SRC}/notes.txt
REFERENCE=${SRC}/reference.txt
rm -rf ${TMP}
mkdir -p ${TMP}
cd ${TMP}
export GIT_SSL_NO_VERIFY=1
git clone git@git.hpcloud.net:DevExDocs/documentation.git
cd documentation
git checkout develop

#
# Release notes
#
cat >${NOTESMD} <<!
---
layout: default
title: "Release Notes for the HP Cloud Services UNIX CLI"
permalink: /cli/unix/release-notes/
product: unix-cli

---
!
cat ${NOTES} >>${NOTESMD}

#
# Reference
#
cat >${REFERENCEMD} <<!
---
layout: default
title: "UNIX CLI: Command Line Reference"
permalink: /cli/unix/reference/
product: unix-cli

---
!
cat ${REFERENCE} >>${REFERENCEMD}
git commit -m 'Jenkins updating Unix CLI release notes and reference' -a
git push origin develop
rm -f ${REFERENCE} ${NOTES}

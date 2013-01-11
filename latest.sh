#!/bin/bash -e
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="documentation-downloads"
rm -f latest
echo ${VERSION} >latest
hpcloud copy -a deploy latest ":${CONTAINER}/unixcli/latest"
rm -f latest

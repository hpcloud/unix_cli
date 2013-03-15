#!/bin/bash -e
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="documentation-downloads"
gem build hpcloud.gemspec
rm -f latest
echo ${VERSION} >latest
hpcloud copy -a deploy latest ":${CONTAINER}/unixcli/latest"
hpcloud copy -a deploy hpcloud-${VERSION}.gem ":${CONTAINER}/unixcli/hpcloud.gem"
rm -f latest

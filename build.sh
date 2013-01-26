#!/bin/bash -e
set -x
TOP=$(pwd)
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="documentation-downloads"
DEST=":${CONTAINER}/unixcli/v${VERSION}/"
FOG_GEM=${FOG_GEM:="hpfog-0.0.18.gem"}
BUILD=
if [ -n "${BUILD_NUMBER}" ]
then
  BUILD=.${BUILD_NUMBER}
fi

#
# Install fog
#
curl -sL https://docs.hpcloud.com/file/${FOG_GEM} >${FOG_GEM}
gem install ${FOG_GEM}
rm -f ${FOG_GEM}

#
# Move to the release branch
#
BRANCH="release/v${VERSION}"
#GIT_SCRIPT=${TOP}/ucssh.sh
#echo 'ssh -i ~/.ssh/id_rsa_unixcli $*' >${GIT_SCRIPT}
#chmod 755 ${GIT_SCRIPT}
#export GIT_SSH=${GIT_SCRIPT}
#git checkout develop || true
git pull || true
git remote prune origin || true
git branch -d ${BRANCH} || git branch -D ${BRANCH} || true
git push origin :${BRANCH} || true
git checkout -b ${BRANCH}
SHA1=$(git log -1 | head -1 | sed -e 's/commit //')

#
# Prepare for release gem
#
grep -v '# Comment out for delivery' lib/hpcloud.rb >out$$
mv out$$ lib/hpcloud.rb
sed -e 's/# Comment in for delivery//g' hpcloud.gemspec >out$$
mv out$$ hpcloud.gemspec
grep -v '# Comment out for delivery' Gemfile >out$$
mv out$$ Gemfile
sed -i -e "s/SHA1.*/SHA1 = '${SHA1}'/" lib/hpcloud/version.rb

#
# Commit, push and tag
#
git commit -m 'Jenkins build new release' -a || true
git push origin ${BRANCH}
git tag -a v${VERSION}${BUILD} -m "v${VERSION}${BUILD}"
git push --tags

#
# Build the gem
#
gem build hpcloud.gemspec
gem install hpcloud-${VERSION}.gem

#
# Copy it up
#
if ! hpcloud containers | grep ${CONTAINER} >/dev/null
then
  hpcloud containers:add :${CONTAINER}
fi
hpcloud copy -a deploy hpcloud-${VERSION}.gem $DEST
hpcloud location -a deploy ${DEST}hpcloud-${VERSION}.gem

rm -f ${REFERENCE} hpcloud-${VERSION}.gem ucssh.sh

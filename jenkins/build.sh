#!/bin/bash -e
export TERM=xterm-256color 
source "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.9.2@unix_cli

bundle install
bundle update

set -x
TOP=$(pwd)
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
FOG_GEM=${FOG_GEM:="hpfog.gem"}
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
git checkout develop || true
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
rm -rf docs.hpcloud.com; git clone git@git.hpcloud.net:DevExDocs/docs.hpcloud.com.git
cp hpcloud-${VERSION}.gem docs.hpcloud.com/file/
cd docs.hpcloud.com/file
git add hpcloud-${VERSION}.gem
git commit -m "add/update new hpcloud-${VERSION}.gem" -a
git push origin master

rm -f ${REFERENCE} hpcloud-${VERSION}.gem ucssh.sh

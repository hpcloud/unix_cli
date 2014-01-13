#!/bin/bash -e
export TERM=xterm-256color 
source "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.9.3@unix_cli

bundle install
bundle update

set -x
TOP=$(pwd)
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
BUILD=
if [ -n "${BUILD_NUMBER}" ]
then
  BUILD=.${BUILD_NUMBER}
fi

#
# Move to the release branch
#
BRANCH="release/v${VERSION}"
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
# Tests
#
rspec spec/unit

#
# Build the gem
#
gem build hpcloud.gemspec
gem install hpcloud-${VERSION}.gem

#
# Copy it up
#
gem push hpcloud-${VERSION}.gem
rm -f ${REFERENCE} hpcloud-${VERSION}.gem

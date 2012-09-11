#!/bin/bash -e
set -x
TOP=$(pwd)
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="documentation-downloads"
DEST=":${CONTAINER}/unixcli/v${VERSION}/"
FOG_GEM=hpfog-0.0.16.gem

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
GIT_SCRIPT=${TOP}/ucssh.sh
echo 'ssh -i ~/.ssh/id_rsa_unixcli $*' >${GIT_SCRIPT}
chmod 755 ${GIT_SCRIPT}
export GIT_SSH=${GIT_SCRIPT}
git push origin ${BRANCH}
git checkout -b ${BRANCH} || git checkout ${BRANCH}

#
# Prepare for release gem
#
grep -v '# Comment out for delivery' lib/hpcloud.rb >out$$
mv out$$ lib/hpcloud.rb
sed -e 's/# Comment in for delivery//g' hpcloud.gemspec >out$$
mv out$$ hpcloud.gemspec
grep -v '# Comment out for delivery' Gemfile >out$$
mv out$$ Gemfile

#
# Commit, push and tag
#
git commit -m 'Jenkins build new release' -a || true
git push origin ${BRANCH}
git tag -a v${VERSION}.${BUILD_NUMBER} -m "v${VERSION}.${BUILD_NUMBER}"
git push --tags

#
# Build the gem
#
gem build hpcloud.gemspec
gem install hpcloud-${VERSION}.gem

#
# Build the reference page
#
set +x
hpcloud help | grep hpcloud | while read HPCLOUD COMMAND ROL
do
  SAVE=''
  STATE='start'
  hpcloud help $COMMAND |
  sed -e 's/Alias:/###Aliases\n /' -e 's/Aliases:/###Aliases\n /' |
  while LINE=$(line)
  do
    case ${STATE} in
    start)
      if [ "${LINE}" == "Usage:" ]
      then
        SAVE="###Syntax\n"
        STATE='usage'
      fi
      ;;
    usage)
      if [ "${LINE}" == "Description:" ]
      then
        echo "## ${COMMAND}"
        STATE='description'
      else
        if [ "${LINE}" == "Options:" ]
        then
          SAVE="###Options\n"
        else
          SAVE="${SAVE}${LINE}\n"
        fi
      fi
      ;;
    description)
      if [ "${LINE}" == "Examples:" ]
      then
        echo -ne "${SAVE}"
        echo "###Examples"
        SAVE=''
        STATE='examples'
      else
        echo "${LINE}"
      fi
      ;;
    examples)
      echo "${LINE}"
      ;;
    esac
  done
  echo
done >reference
set -x

#
# Copy it up
#
if ! hpcloud containers | grep ${CONTAINER} >/dev/null
then
  hpcloud containers:add :${CONTAINER}
fi
hpcloud copy -a deploy hpcloud-${VERSION}.gem $DEST
hpcloud copy -a deploy CHANGELOG $DEST
hpcloud copy -a deploy reference CHANGELOG $DEST
hpcloud acl:set -a deploy ${DEST}CHANGELOG public-read
hpcloud acl:set -a deploy ${DEST}reference public-read
hpcloud acl:set -a deploy ${DEST}hpcloud-${VERSION}.gem public-read

rm -f reference hpcloud-${VERSION}.gem ucssh.sh

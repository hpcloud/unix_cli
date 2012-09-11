TOP=$(pwd)
export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="unixcli"
DEST=":${CONTAINER}/${VERSION}/"
FOG_GEM=hpfog-0.0.16.gem

#
# Install fog
#
curl -sL https://docs.hpcloud.com/file/${FOG_GEM} >${FOG_GEM}
gem install ${FOG_GEM}
rm -f ${FOG_GEM}

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
# Build the gem
#
gem build hpcloud.gemspec
gem install hpcloud-${VERSION}.gem

#
# Build the reference page
#
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

#
# Copy it up
#
if ! hpcloud containers | grep ${CONTAINER} >/dev/null
then
  hpcloud containers:add :${CONTAINER}
fi
hpcloud copy hpcloud-${VERSION}.gem $DEST
hpcloud copy CHANGELOG $DEST
hpcloud copy reference CHANGELOG $DEST
hpcloud acl:set :${CONTAINER} public-read
hpcloud acl:set ${DEST}CHANGELOG public-read
hpcloud acl:set ${DEST}reference public-read
hpcloud acl:set ${DEST}hpcloud-${VERSION}.gem public-read

rm -f reference hpcloud-${VERSION}.gem

#
# Restore modified files
#
git checkout lib/hpcloud.rb
git checkout hpcloud.gemspec
git checkout Gemfile

#
# Tag
#
set -x
GIT_SCRIPT=${TOP}/ucssh.sh
echo 'ssh -i ~/.ssh/id_rsa_unixcli $*' >${GIT_SCRIPT}
chmod 755 ${GIT_SCRIPT}
export GIT_SSH=${GIT_SCRIPT}
git tag -a v${VERSION}.${BUILD_NUMBER} -m "v${VERSION}.${BUILD_NUMBER}"
git push --tags

export `grep VERSION lib/hpcloud/version.rb | sed -e 's/ //g' -e "s/'//g"`
CONTAINER="unixcli"
DEST=":${CONTAINER}/${VERSION}/"

#
# Prepare for release gem
#
grep -v '# Comment out for delivery' lib/hpcloud.rb >out
mv out lib/hpcloud.rb
sed -e 's/# Comment in for delivery//g' hpcloud.gemspec >out
mv out hpcloud.gemspec

#
# Build the gem
#
gem build hpcloud.gemspec
gem install hpcloud-${VERSION}.gem

#
# Restore modified files
#
git checkout lib/hpcloud.rb
git checkout hpcloud.gemspec

#
# Build the reference page
#
hpcloud help | grep hpcloud | while read HPCLOUD COMMAND ROL
do
  SAVE=''
  STATE='start'
  hpcloud help $COMMAND | sed -e 's/Alias:/###Aliases\n /' |
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
        SAVE="${SAVE}${LINE}\n"
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
hpcloud acl:set ${DEST}CHANGELOG public-read
hpcloud acl:set ${DEST}reference public-read
hpcloud acl:set ${DEST}hpcloud-${VERSION}.gem public-read

rm -f reference hpcloud-${VERSION}.gem

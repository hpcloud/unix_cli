#!/bin/bash
#
# Build the bash complete
#
COLUMNS=256;
LINES=24;
export COLUMNS LINES;
OFILE=completion/hpcloud

echo '_hpcloud()' >${OFILE}
echo '{' >>${OFILE}
echo '  local cur prev opts cmds cmd files' >>${OFILE}
echo '  COMPREPLY=()' >>${OFILE}
echo '  _get_comp_words_by_ref -n : cur prev words' >>${OFILE}
echo >>${OFILE}
echo '  if [[ ${cur} == -* ]] ; then' >>${OFILE}
echo '    if [ "${prev}" == "hpcloud" ]' >>${OFILE}
echo '    then' >>${OFILE}
echo '      cmd="hpcloud"' >>${OFILE}
echo '    else' >>${OFILE}
echo '      cmd="${words[1]}"' >>${OFILE}
echo '    fi' >>${OFILE}
echo '    case "${cmd}" in' >>${OFILE}
echo '    hpcloud)' >>${OFILE}
echo '      opts="--help --version"' >>${OFILE}
echo '      ;;' >>${OFILE}

#
# Get the options
#
hpcloud help | grep hpcloud | while read HPCLOUD COMMAND ROL
do
  OPT=''
  SEPER=''
  STATE='start'
  hpcloud help $COMMAND |
  while read LINE
  do
    case ${STATE} in
    start)
      if [ "${LINE}" == "Options:" ]
      then
        STATE='options'
        echo "    ${COMMAND})" >>${OFILE}
      fi
      ;;
    options)
      if [ "${LINE}" == "Description:" ]
      then
        echo "      opts=\"${OPT}\"" >>${OFILE}
        echo "      ;;" >>${OFILE}
        STATE='stop'
      else
        LINE=$(echo $LINE | sed -e 's/.*--/--/' -e 's/\].*//' -e 's/=.*//')
        OPT="${OPT}${SEPER}${LINE}"
        SEPER=' '
      fi
      ;;
    stop)
      ;;
    esac
  done
done

echo "    esac" >>${OFILE}
echo '    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )' >>${OFILE}
echo '    return 0' >>${OFILE}
echo "  fi" >>${OFILE}


#
# Get the commands
#
echo '  if [ "${prev}" == "hpcloud" ]' >>${OFILE}
echo '  then' >>${OFILE}
SPACER=''
echo -n '    cmds="' >>${OFILE}
hpcloud help | grep hpcloud | while read HPCLOUD COMMAND ROL
do
  echo -n "${SPACER}${COMMAND}" >>${OFILE}
  SPACER=' '
done
echo '"' >>${OFILE}
echo '    COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )' >>${OFILE}
echo '    __ltrim_colon_completions "$cur"' >>${OFILE}
echo '    return 0' >>${OFILE}
echo '  fi' >>${OFILE}
echo  >>${OFILE}
echo '  cmd="${words[1]}"' >>${OFILE}
echo '  if [ "${cmd}" == "copy" ]' >>${OFILE}
echo '  then' >>${OFILE}
echo '    _compopt_o_filenames' >>${OFILE}
echo '    COMPREPLY=( $( compgen -f -- "$cur" ) $( compgen -d -- "$cur" ) )' >>${OFILE}
echo '    return 0' >>${OFILE}
echo '  fi' >>${OFILE}
echo '  return 0' >>${OFILE}
echo '}' >>${OFILE}
echo 'complete -F _hpcloud hpcloud' >>${OFILE}

#CONTAINER="documentation-downloads"
#DEST=":${CONTAINER}/unixcli/"
#hpcloud copy -a deploy ${OFILE} $DEST
#hpcloud location -a deploy ${DEST}${OFILE}


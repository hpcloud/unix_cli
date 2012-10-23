#!/bin/bash -e
#
# Build the reference page
#
REFERENCE=reference.txt
echo 'Below you can find a full reference of supported UNIX command-line interface (CLI) commands. The commands are alphabetized.  You can also use the <font face="Courier">hpcloud help [<em>command</em>]</font> tool (where <em>command</em> is the name of the command on which you want help, for example <font face="Courier">account:setup</font>) to display usage, description, and option information from the command line.' >${REFERENCE}
echo >>${REFERENCE}
hpcloud help | grep hpcloud | while read HPCLOUD COMMAND ROL
do
  SAVE=''
  STATE='start'
  hpcloud help $COMMAND |
  sed -e 's/Alias:/###Aliases\n /' -e 's/Aliases:/###Aliases\n /' |
  while read LINE
  do
    case ${STATE} in
    start)
      if [ "${LINE}" == "Usage:" ]
      then
        SAVE="###Syntax\n<font face=\"Courier\">"
        STATE='usage'
      fi
      ;;
    usage)
      LINE=$(echo ${LINE} | sed -e 's/\[/\[ITALICS_START/g' -e 's/]/ITALICS_END]/g' -e 's/</\&lt;ITALICS_START/g' -e 's,>,ITALICS_END\&gt;,g' -e 's/ITALICS_START/<i>/g' -e 's,ITALICS_END,</i>,g' )
      SAVE="${SAVE}${LINE}</font>\n"
      STATE='options'
      ;;
    options)
      if [ "${LINE}" == "Description:" ]
      then
        echo "## ${COMMAND}"
        STATE='description'
      else
        if [ "${LINE}" == "Options:" ]
        then
          SAVE="${SAVE}###Options\n"
        else
          if [ "${LINE}" == "" ]
          then
            SAVE="${SAVE}${LINE}\n"
          else
            SAVE="${SAVE}${LINE}  \n"
          fi
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
      if [ "${LINE}" == "###Aliases" ]
      then
        echo "${LINE}"
        STATE='examples'
        STATE='aliases'
      else
        echo "    ${LINE}"
      fi
      ;;
    aliases)
      echo "${LINE}"
      ;;
    esac
  done
  echo
done >>${REFERENCE}

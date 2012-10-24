#!/bin/bash
#
# Build the reference page
#
function courierizer { echo $1 | sed -e "s,<\([^>]*\)>,<i>\1</i>,g" -e "s,'\([^']*\)',<font face='courier'>\1</font>,g"; }
REFERENCE=reference.txt
echo 'Below you can find a full reference of supported UNIX command-line interface (CLI) commands. The commands are alphabetized.  You can also use the <font face="Courier">hpcloud help [<em>command</em>]</font> tool (where <em>command</em> is the name of the command on which you want help, for example <font face="Courier">account:setup</font>) to display usage, description, and option information from the command line.' >${REFERENCE}
echo >>${REFERENCE}
hpcloud help | grep hpcloud | grep cdn:containers | while read HPCLOUD COMMAND ROL
do
  SAVE=''
  STATE='start'
  SHORT=$(echo $ROL | sed -e 's/.*# //')
  export SHORT
  hpcloud help $COMMAND |
  sed -e 's/Alias:/###Aliases\n /' -e 's/Aliases:/###Aliases\n /' |
  while true
  do
    read LINE
    if [ $? -ne 0 ]
    then
      if [ "${SAVE}" ]
      then
        echo
        echo -ne "${SAVE}"
        SAVE=''
      else
        echo
      fi
      break
    fi
    case ${STATE} in
    start)
      if [ "${LINE}" == "Usage:" ]
      then
        echo -ne "<h2 id=\"${COMMAND}\">${COMMAND}</h2>\n${SHORT}\n\n"
        echo "###Syntax"
        STATE='usage'
      fi
      ;;
    usage)
      if [ "${LINE}" == "Options:" ]
      then
        SAVE="\n\n###Options\n"
        STATE='options'
      else
        if [ "${LINE}" ]
        then
          LINE=$(echo ${LINE} | sed -e 's/\[/\[ITALICS_START/g' -e 's/]/ITALICS_END]/g' -e 's/</\&lt;ITALICS_START/g' -e 's,>,ITALICS_END\&gt;,g' -e 's/ITALICS_START/<i>/g' -e 's,ITALICS_END,</i>,g' )
          echo -ne "<font face=\"Courier\">${LINE}</font>"
        fi
      fi
      ;;
    options)
      if [ "${LINE}" == "Description:" ]
      then
        echo -ne "${SAVE}###Description\n"
        SAVE=''
        STATE='description'
      else
        if [ "${LINE}" == "" ]
        then
          SAVE="${SAVE}${LINE}\n"
        else
          SAVE="${SAVE}${LINE}  \n"
        fi
      fi
      ;;
    description)
      if [ "${LINE}" == "Examples:" ]
      then
        echo "###Examples"
        STATE='examples'
      else
        courierizer "${LINE}"
      fi
      ;;
    examples)
      if [ "${LINE}" == "###Aliases" ]
      then
        echo "${LINE}"
        STATE='examples'
      else
        echo "    ${LINE}"
      fi
      ;;
    aliases)
      echo "${LINE}"
      ;;
    esac
  done
done >>${REFERENCE}

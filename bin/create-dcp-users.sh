#!/bin/bash

if [ "${BASH_VERSINFO}" -lt 4 ]; then
    echo "This script requires bash 4.0 or greater."
    exit 1
fi

declare -A SUDOLIST

GROUPLIST="docker,sudo"

SUDOLIST=( \
    ["user1"]="FIRST_LAST1" \
    ["user2"]="FIRST LAST2" \
    

for USER in ${!SUDOLIST[@]}; do
  if [ "`id $USER 2>/dev/null`" = "" ]; then
    echo "DCP-USER: creating $USER account"
    useradd -m --shell /bin/bash -G "$GROUPLIST" -c "${SUDOLIST[$USER]}" $USER
    echo "asdf\nasdf" | passwd $USER
  else
    echo "DCP-USER: updating $USER account adding them to groups $GROUPLIST"
    usermod -a -G "$GROUPLIST" $USER
  fi
done

gpasswd -d buildmeister sudo

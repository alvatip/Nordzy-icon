#!/bin/bash

#
#
#

ROOT_UID=0
DEST_DIR=

# Check root user
if [ "$UID" -eq "$ROOT_UID" ]; then
  THEME_DIR="/usr/share/icons"
else
  THEME_DIR="$HOME/.local/share/icons"
fi

# Remove the Nordzy-icons file without removing potential Nordzy-cursors files
remove_icons() {
for folder in ${THEME_DIR}/*
do
  if [[ ${folder} =~ Nordzy-cursors* ]]; then
    :
  elif [[ ${folder} =~ Nordzy* ]];then
    rm -rf ${folder}
  fi
done
}

remove_icons
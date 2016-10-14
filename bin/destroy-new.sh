#!/bin/bash

################################################################################
####
####   bin/destroy-new.sh
####     @package: "Blueprints"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   This file is sourced from the blueprints package. It should
####              not be used as a stand alone executable. It will completely
####              remove a "new"/"blueprints" templates folder from system.
####

EDITOR=${EDITOR:-vi}
PAGER=${PAGER:-less}
new_destroy_folder="$NEW_TEMPLATES_DIR/$blueprint"

if [ -z "$blueprint" ];then
  exit_with_code $E_MISS
fi


if [ -d $new_destroy_folder ];then
  # PROMPT THE USER IF THEY WANT TO OVERWRITE/EDIT/EXIT
  echo  -e "  About to completely remove template $blueprint!"
  echo -n "     - Are you sure?  -press y/n then [ENTER]"
  read ans
  if [ $? != 0 ] || [[ ! $ans =~ ^y(es)?$ ]];then
    add_verbose_msg "fewww, that was close, exiting instead of destroying folder"
    exit_with_code $EXIT_USER
  fi
  # Remove
  rm -r $new_destroy_folder
  # Make sure the directory no longer exists
  if [ -d $new_destroy_folder ];then
    add_verbose_msg "Unable to remove folder, try 'rm -rf $new_destroy_folder'"
  else
    add_verbose_msg "Removed template $blueprint"
  fi

else
  # The directory to destroy doesn't exist
  echo "  Unable to destroy blueprint \"$blueprint\" because it can't be found!"
  echo "    - hint: running \`new list\` should display local templates."
fi

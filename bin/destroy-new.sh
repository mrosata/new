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
new_create_folder="$NEW_TEMPLATES_DIR/$blueprint"

if [ -z "$blueprint" ];then
  exit_with_code 65
fi


if [ -d $new_create_folder ];then
  # PROMPT THE USER IF THEY WANT TO OVERWRITE/EDIT/EXIT
  echo  "About to completely remove template $blueprint\!"
  echo -n "   - Are you sure?  -press y/n then [ENTER]"
  read ans
  if [ $? != 0 ] || [[ ! $ans =~ ^y(es)?$ ]];then
    add_verbose_msg "fewww, that was close, exiting instead of destroying folder"
    exit_with_code $EXIT_USER
  fi
  # Remove
  rm -r $new_create_folder
  # Make sure the directory no longer exists
  if [ -d $new_create_folder ];then
    add_verbose_msg "Unable to remove folder, try 'rm -rf $new_create_folder'"
  else
    add_verbose_msg "Removed template $blueprint"
  fi

else
  # The directory to destroy doesn't exist
  add_verbose_msg "Template $blueprint doesn't exist so it can't be destroyed"
fi

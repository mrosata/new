#!/bin/bash

################################################################################
####
####   bin/create-new.sh
####     @package: "Blueprints"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   This file is sourced from the blueprints package. It should
####              not be used as a stand alone executable. It is used to 
####              create a new template config file, folder, and template file.
####

EDITOR=${EDITOR:-vi}
PAGER=${PAGER:-less}
new_create_folder="$NEW_TEMPLATES_DIR/$blueprint"
new_create_template="$new_create_folder/template"
template_from_file="$destname"

if [ -z "$blueprint" ] || [ -z "$EDITOR" ];then
  exit_with_code 65
fi


if [ -d $new_create_folder ];then
  # PROMPT THE USER IF THEY WANT TO OVERWRITE/EDIT/EXIT.
  echo  "The template $blueprint already exists!"
  echo -n "   - Would you like to overwrite?  -press y/n then [ENTER]"
  read ans
  if [ $? != 0 ] || [[ ! $ans =~ ^y(es)?$ ]];then
    exit_with_code $EXIT_USER
  fi
  # Remove
  add_verbose_msg "removing folder $new_create_folder"
  rm -r $new_create_folder
fi

# Make the new templates folder.
add_verbose_msg "creating directories $new_create_folder"
mkdir $new_create_folder
# Check that the directory created ok.
if [ ! -d "$new_create_folder" ];then
  exit_with_code $E_DIRERR
fi

add_verbose_msg "creating new configuration file"
(
  # work in a subshell while changing directories.
  cd $new_create_folder
  # create the configuration file with basic info.
  touch ".new-conf"
  echo -e "template=template\nnewpath=\nafter=\n" >> .new-conf
)

add_verbose_msg "creating new template file $new_create_template"
touch "$new_create_template"
# Now see if user passed in a template file to use.
if [ -n "$template_from_file" ] && [ -f "$template_from_file" ];then
  add_verbose_msg "using file $template_from_file as template"
  cp -T "$template_from_file" "$new_create_template"
fi

if [ "$EDIT_ON_CREATE" -eq "1" ];then
  # open the blueprint file for edit.
  $EDITOR "$new_create_folder/$blueprint"
fi

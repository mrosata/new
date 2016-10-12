#!/bin/bash

################################################################################
####
####   bin/create-new.sh
####     @package: "Blueprints"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   This file is sourced from the blueprints package. It should
####              not be used as a stand alone executable. It is used to 
####              generate new boilerplate files into a working folder from
####              information supplied inside a config file.
####

EDITOR=${EDITOR:-vi}
PAGER=${PAGER:-less}

# $blueprint_folder
# $blueprint_config


if [ -z "$blueprint_folder" ] || [ -z "$blueprint_config" ] || [ -z "$destname" ];then
  exit_with_code 65
fi

#### source the configuration file
. "$blueprint_config"
config_out_folder=$newpath
config_filename=$template
template_file="$blueprint_folder/$config_filename"
if [ -n "$config_out_folder" ];then
  new_generated_dest="$TARGET_DIR/$config_out_folder/$destname"
else
  new_generated_dest="$TARGET_DIR/$destname" 
fi

add_verbose_msg "- source: $template_file"
add_verbose_msg "- dest: $new_generated_dest"


################################################################################
#### 
#### Backups
####

# Check that directory where we are going to write file exists.
absdir_new_generated_dest=$(dirname "$new_generated_dest")
if [ ! -d "$absdir_new_generated_dest" ]
  then
    #// TODO Should check if create directory is set
    add_verbose_msg "directory not exists: $absdir_new_generated_dest"
    exit_with_code $E_DSTERR
  else
    # We need to make sure this really is absolute because
    # we'll use it to find backups so relative could break
    absdir_new_generated_dest=$(readlink -f "$absdir_new_generated_dest")
fi


# Backup the current file if we're going to overwrite a file.
if [ "$NO_BACKUPS" -eq "0" ];then

  # Check if base backup dir exists
  if [ ! -d "$NEW_BACKUP_DIR" ];then
    exit_with_code $E_BKUPERR
  fi

  # If destname file exists we are ready to start backup process
  if [ -f "$new_generated_dest" ];then

    # Destination path should be mirrored in backup (for easier restores)
    dest_dir_backup="$NEW_BACKUP_DIR$absdir_new_generated_dest"
    if [ ! -d $dest_dir_backup ];then
      add_verbose_msg "creating backup dir: $dest_dir_backup"
      if [ "$NO_CHANGE" -eq "0" ];then
        mkdir -p $dest_dir_backup
      fi
    fi

    add_verbose_msg "backing up file: $dest_dir_backup/$(basename $destname)"
    if [ "$NO_CHANGE" -eq "0" ];then
      cp "$new_generated_dest" "$dest_dir_backup"
    fi

  else

    #destination file or backup folder doesn't exist
    if [ ! -f "$new_generated_dest" ];then
      add_verbose_msg "nothing to backup"
    fi

  fi
fi


################################################################################
####
#### Generate boilerplate out to destination
####

# Check user didn't set no changes
if [ "0" -eq "$NO_CHANGE" ];then
  cp "$template_file" "$new_generated_dest"
fi

unset new_generated_dest
unset dest_dir_backup
unset absdir_new_generated_dest
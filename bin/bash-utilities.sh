#!/bin/bash

################################################################################
####
####  Utilities for Bash Shell Scripts...
####    @author: mrosata
####    @date:   10-11-2016
####



# Run $2 if $1 is directory[, else run $3 ]
function if_directory () {
  if [ -d "$1" ]
    then
      ( $2 )
    else
      if [ -n "$3" ];then
        ( $3 )
      fi
  fi
}


# Run $2 if $1 is file[, else run $3 ]
function if_file () {
  if [ -f "$1" ]
    then
      ( $2 )
    else
      if [ -n "$3" ];then
        ( $3 )
      fi
  fi
}


# Add to verbose message
function add_verbose_msg () {
  VERBOSE_MSG="$VERBOSE_MSG\n$1"
}


# most of this function copied @ StackOverflow
#   http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in
function root_script_directory () {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    TARGET="$(readlink "$SOURCE")"
    if [[ $TARGET == /* ]]; then
      SOURCE="$TARGET"
    else
      DIR="$( dirname "$SOURCE" )"
      SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    fi
  done
  RDIR="$( dirname "$SOURCE" )"
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

  # If argument 1 is "1" then echo dir
  if [ "1" -eq "$1" ];then
    echo -n $DIR
  fi
  # set a global var, unset the rest.
  ROOT_SCRIPT_DIR=$DIR

  unset DIR
  unset SOURCE
}

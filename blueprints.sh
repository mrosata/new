#!/bin/bash

################################################################################
####
####   "Blueprints"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   Blueprints creates new boilerplate files based on templates
####              placed inside $NEW_TEMPLATES_DIR. See the section titled
####              "Will-Change" for a list of future features that are planned
####
####

EDITOR=${EDITOR:-vi}
PAGER=${PAGER:-less}

program_description="
  This script is intended to make your boilerplate code not only easier to
  manage, but also simplier to setup, configure and share. You can quickly
  add a new empty template to the system or generate a template from a file
  that is already on your computer. Eventually you will be able to include
  config files within projects that define boilerplate components/templates 
  for that project.
"

program_instruction="
  new [COMMAND] [-nhvfBe] [-tb DIRECTORY] BLUEPRINT DEST

  \"Required Information\"

    BLUEPRINT
      - Name of blueprint template to use. The \"BLUEPRINT\" name will be
        used to determine how to create, store, reproduce, edit and remove
        a specific blueprint.

    DEST
      - Name to be used in the templates recreated by the script inside you
        project or working folder. In the case that multiple files are created
        by a blueprint, the configuration file should handle ensuring that
        no collisions occur


  \"Variables\"

    -t TARGET_DIR
        This variable is the target root directory. If you are in directory
        \"/projects\" then by default TARGET_DIR=\"/projects\", but that may not
        be where generated boilerplate files go. For instance, a configuration
        file might set a base_dir=\"app\" in which case that boilerplate file
        would be created in \"/projects/app\".

    -b BACKUP_DIR
        In most cases generated boilerplate shouldn't overwrite other files, but 
        in the case where a file is overwritten a backup is created (unless user
        explicity sets -B). Generally you should not care to touch this variable.
        If you change this variable for a run, you also need to set it if and 
        when you want to restore the old file.


  \"Flags\"
    
    -h   \"Help\", show this screen.
    -n   \"No change\", meaning no files will be created/altered/removed this run.
    -v   \"Verbose\", the verbosity level can be set by using multiple \"v\" flags
    -f   \"\",
    -B   \"No Backup\", if a file is overwritten do not create a backup. Generally
         templates shouldn't overwrite files.
    -e   \"Edit\", open editor upon any change. Uses the global EDITOR|-vi

"

################################################################################
####
####  "Environment Variables"
####  
####  -configurable by environment (configs w/defaults if not already set)
####    NEW_SCRIPTPATH    ->  ~/bin/new
####    NEW_TEMPLATE_DIR  ->  ~/bin/custom/templates  -->  "template storage"
####

# push the directory of this script onto dir stack to save the directory
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

NEW_SCRIPTPATH="${NEW_SCRIPTPATH:-$SCRIPTPATH}" # base of template & backups
NEW_IMPORTS_DIR="$NEW_SCRIPTPATH/bin"
NEW_TEMPLATES_DIR="${NEW_TEMPLATES_DIR:-$NEW_SCRIPTPATH/templates}"
NEW_BACKUP_DIR="${NEW_BACKUP_DIR:-$NEW_SCRIPTPATH/.backups}"


################################################################################
####
####   "Usage"
####      
####      Assuming we have an alias for blueprint.sh
####      alias new='`$HOME`/bin/blueprint.sh'
####     new templatename destpath
####

function print_program_description() {
  echo "  \"new\" AKA \"blueprints.sh\"
    Flexible blueprinting. Pass -h for help"
}

function print_program_help() {
  echo -ne program_description
  echo -ne program_instruction
}

function show_folder_locations() {
  echo "
  New (blueprints) folder locations:

  - Template directory: 
      $NEW_TEMPLATES_DIR
  - Write directory: 
      $TARGET_DIR"
}


################################################################################
####
####  "Source Scripts"
####

new_utils_file="$NEW_IMPORTS_DIR/bash-utilities.sh"
if [ ! -f "$new_utils_file" ];then
  echo "Could not find $new_utils_file which are required for new to run."
  exit 30;
fi
. $new_utils_file


################################################################################
####
####  "Variables and Exit Codes"
####
####  -exit codes
####     EXIT_OK   ->  0   -->  "Successful exit"
####     E_TMPERR  ->  11  -->  "Template not found"
####     E_DSTERR  ->  12  -->  "Destination files directory not exist"
####	   E_BKUPERR ->  13  -->  "Base backup directory not exist"
####	   E_OPTERR  ->  65  -->  "Invalid Argument"
####

# Base Variables
VERBOSE_MSG=""

# Exit Codes
EXIT_OK=0
EXIT_USER=1
E_OPTERR=65
E_TMPERR=11
E_DSTERR=12
E_BKUPERR=13
E_DIRERR=14

function exit_with_code() {

  # If verbose was set then show messages
  if [ "$VERBOSE" -gt "0" ];then
    echo -e "$VERBOSE_MSG"
  fi

  # Echo out error message
  if [ "$1" -gt "0" ];then
    case $1 in
  	  $E_OPTERR)
	      echo "  Error: invalid option" >&2
	      ;;
    $E_TMPERR)
        echo "  Error: template error" >&2
        ;;
    $E_DIRERR)
        echo "  Error: directory error" >&2
        ;;
    $E_DSTERR)
        echo "  Error: destination error" >&2
        ;;
    $E_BKUPERR)
        echo "  Error: backup directory error" >&2
        ;;
    esac
  fi

  exit $1
}


################################################################################
####
####   "Options"
####
####      -t DIRECTORY  - "target - Target directory, defaults to current."
####      -v            - "verbose - display what changes will be made."
####	    -n            - "No Change - don't actually make changes, trial run."
####      -f            - "Folders - show the folder locations"
####      -b            - "Backup folder" - default to $NEW_SCRIPTPATH/backups
####      -B            - "No backups" - default is to create backups
####      -e            - "Edit on create" - use flag to edit new blueprint
####

# Arguments
CREATE_NEW=0
EDIT_ON_CREATE=0
DESTROY_TEMPLATE=0
TARGET_DIR=$(pwd)
UNKNOWN_ARG=0       # This turns to 1 if unknown arg is passed.
NO_BACKUPS=0
NO_CHANGE=0
VERBOSE=0

# If there are no arguments passed in, show description
if [ "$#" -lt 2 ]
then
  if [ "$1" = "-h" ];then
    print_program_help
    exit_with_code $E_OPTERR
  else
    print_program_description
    exit_with_code $E_OPTERR
  fi
fi


if [ "$1" = "new" ];then
  CREATE_NEW=1
  shift
fi

if [ "$1" = "destroy" ] || [ "$1" = "rm" ] || [ "$1" = "remove" ];then
  DESTROY_TEMPLATE=1
  shift
fi

# Parse command line args
while getopts "t:b:hnvfbBe" opt
do
  case $opt in
    # No Change for test mode.
  	n)
      NO_CHANGE=1
      add_verbose_msg "run will make no changes to system"
      ;;
    # Verbose level increment (IE: -vvv would result in VERBOSE == 3 )
    v)
      VERBOSE=$(( $VERBOSE + 1 ))
      ;;
    h)
      print_program_help
      exit_with_code $EXIT_OK
      ;;
    # Show folder locations and exit.
    f)
      show_folder_locations
      exit_with_code $EXIT_OK
      ;;
    # Set target directory (optional)
    t)
      TARGET_DIR="$OPTARG"
      add_verbose_msg "set target dir to $TARGET_DIR"
      ;;
    # Set backup directory (optional)
    b)
      NEW_BACKUP_DIR="$OPTARG"
      add_verbose_msg "set backup directory set as $NEW_BACKUP_DIR"
      ;;
    B)
      NO_BACKUPS=1
      add_verbose_msg "run will not create any backup"
      ;;
    e)
      EDIT_ON_CREATE=1
      add_verbose_msg "will edit template file (if in 'new' mode)"
      ;;
    # Invalid Arguments. Display if verbose
    \?)
      UNKNOWN_ARG=1
      add_verbose_msg "invalid option: -$opt $OPTARG"
      ;;
  esac
done

# Check for 2 positional args: template and destination filename
blueprint=${@:$OPTIND:1}
destname=${@:$OPTIND+1:1}
if [ "$CREATE_NEW" -eq "1" ];then
  . "$NEW_IMPORTS_DIR/create-new.sh"
  exit_with_code $EXIT_OK
fi

if [ "$DESTROY_TEMPLATE" -eq "1" ];then
  . "$NEW_IMPORTS_DIR/destroy-new.sh"
  exit_with_code $EXIT_OK
fi

if [ -z "$blueprint" ] || [ -z "$destname" ];then
  echo "Must pass blueprint name and destname as last 2 positional args"
fi

# Exit from unknown only after all args passed.
if [ "$UNKNOWN_ARG" -gt "0" ];then
  exit_with_code $E_OPTERR
fi


# Now that we have arguments, it is time to build those arguments
# into folders and filenames to look up information required to 
# do the read and write.

# Check that template folder exists.
blueprint_folder="$NEW_TEMPLATES_DIR/$blueprint"
blueprint_config="$blueprint_folder/.new-conf"
if [ ! -d "$blueprint_folder" ] || [ ! -f "$blueprint_config" ];then
  add_verbose_msg "new template $blueprint does not exists in folder $blueprint_folder"
  exit_with_code $E_TMPERR
fi

# Generate the boilerplate code
. "$NEW_IMPORTS_DIR/generate-new.sh"

# Exit Successfully 
exit_with_code $EXIT_OK

################################################################################
####
####   "Will-Change"
####     >- $NEW_TEMPLATES_DIR will be a "default" value which shall easily   
####        be overwritten by any number of configuration files located in  
####        the users $HOME_DIR or project folders.
####     >- Somehow variables will be available for use inside templates. This
####        feature requires fore-thought since blueprints should work for any
####		file type it must be careful about how it chooses to differenciate
####        between variables intented to be templated in and similar syntax 
####        that is just meant to be part of the template. (perhaps the variables)
####        will be explict mappings between search and replace values)
####        
####    >- There will be a restore. The backup is already done.        
####        
####
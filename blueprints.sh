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

function program_instruction () {
  # Echo out long description
  . "$SCRIPTPATH/bin/.program-instruction"
}


################################################################################
####
####  "Environment Variables"
####  
####  -configurable by environment (configs w/defaults if not already set)
####    NEW_TEMPLATE_DIR  ->  $SCRIPTPATH/templates  -->  "template storage"
####    NEW_BACKUP_DIR    ->  $SCRIPTPATH/.backups   -->  "backups storage"
####

# push the directory of this script onto dir stack to save the directory
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

NEW_IMPORTS_DIR="$SCRIPTPATH/bin"
NEW_TEMPLATES_DIR="${NEW_TEMPLATES_DIR:-$SCRIPTPATH/templates}"
NEW_BACKUP_DIR="${NEW_BACKUP_DIR:-$SCRIPTPATH/.backups}"

function run_create_new_script() 
  { . "$NEW_IMPORTS_DIR/create-new.sh"; }

function run_destroy_script()
  { . "$NEW_IMPORTS_DIR/destroy-new.sh"; }

function run_generate_new_script ()
  { . "$NEW_IMPORTS_DIR/generate-new.sh"; }

################################################################################
####
####   "Usage"
####      
####      Assuming we have an alias for blueprint.sh
####      alias new='`$HOME`/bin/blueprint.sh'
####     new templatename destpath
####

function print_small_description() {
  echo "  \"new\" AKA \"blueprints.sh\"
    Flexible blueprinting. Pass -h for help"
}

function print_program_help() {
  program_instruction | $PAGER
}

# Shows all the templates in the new templates directory 
function display_templates_list () {
  if [ -d "$NEW_TEMPLATES_DIR" ];then
    echo "Found $(ls -1 $NEW_TEMPLATES_DIR | wc -l) templates:"
    list_subdirectories_in $NEW_TEMPLATES_DIR '    '
  fi
}

function show_folder_locations() {
  echo "
  New (blueprints) folder locations (mainly for debug purposes):

  - New bin directory (where program is):
      $SCRIPTPATH
  - Template directory: 
      $NEW_TEMPLATES_DIR
  - Base Write directory (your dir): 
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
####     EXIT_OK     ->  0   -->  "Successful exit"
####     EXIT_USER   ->  1   -->  "User prompted exit (maybe a y/n prompt)"
####     E_DSTERR    ->  11  -->  "Destination files directory not exist"
####     E_BKUPERR   ->  12  -->  "Base backup directory not exist"
####     E_DIRERR    ->  12  -->  "Directory error"
####     E_TMPERR    ->  21  -->  "Template not found"
####     E_NAMERR    ->  22  -->  "Name not allowed"
####     E_EMTYOPT   ->  41  -->  "Zero Arguments"
####	   E_OPTERR    ->  42  -->  "Invalid Argument"
####

# Base Variables
VERBOSE_MSG=

# Exit Codes
EXIT_OK=0
EXIT_USER=1
# Directory errors
E_DSTERR=11
E_BKUPERR=12
E_DIRERR=13
# run specific errors
E_TMPERR=21
E_NAMERR=22
# Option errors
E_EMTYOPT=41
E_OPTERR=42

# Exit the program and also display an error message if
# the argument $1 is an error code (greater than 0) 
function exit_with_code() {

  # If verbose was set then show messages
  if [ "$VERBOSE" -gt "0" ];then
    echo -e "$VERBOSE_MSG"
  fi

  # Echo out error message
  if [ "$1" -gt "0" ];then
    case $1 in
      $E_EMTYOPT)
        echo "  Warning: No options found."
        ;;
  	  $E_OPTERR)
	      echo "  Error: invalid option." >&2
	      ;;
      $E_TMPERR)
        echo "  Error: template error." >&2
        ;;
      $E_DIRERR)
        echo "  Error: directory error." >&2
        ;;
      $E_DSTERR)
        echo "  Error: destination error." >&2
        ;;
      $E_BKUPERR)
        echo "  Error: backup directory error." >&2
        ;;
      $E_NAMERR)
        echo "  Error: Name not allowed." >&2
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
####      -b            - "Backup folder" - default to $SCRIPTPATH/backups
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


# Check if user passed -h|help -l|list or info
function check_arguments_help_info_list () {
  if [ "$1" = "-h" ] || [ "$1" = "help" ];then
    print_program_help
    exit_with_code $EXIT_OK
  
  elif [ "$1" = "-l" ] || [ "$1" = "list" ];then
    display_templates_list
    exit_with_code $EXIT_OK
  
  elif [ "$1" = "info" ];then
    print_small_description
    exit_with_code $EXIT_OK
  fi
}


check_arguments_help_info_list "$1"

# If there are no arguments passed in, show description
if [ "$#" -eq "0" ]
then
  print_small_description
  exit_with_code $E_EMTYOPT
fi


if [ "$1" = "new" ];then
  CREATE_NEW=1
  shift
fi

if [ "$1" = "destroy" ];then
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
      add_verbose_msg "unknown argument: -$opt $OPTARG"
      ;;
  esac
done

# Check for 2 positional args: template and destination filename
blueprint=${@:$OPTIND:1}
destname=${@:$OPTIND+1:1}

if [ "$CREATE_NEW" -eq "1" ]
  then
    run_create_new_script
    exit_with_code $EXIT_OK

elif [ "$DESTROY_TEMPLATE" -eq "1" ]
  then
    run_destroy_script
    exit_with_code $EXIT_OK
fi


# Exit from unknown only after all args passed.
if [ "$UNKNOWN_ARG" -gt "0" ];then
  exit_with_code $E_OPTERR
fi


# NOTE: This test should only be reached if there isn't some pre-argument
#       commands run such as `new`, `destroy` or `edit`. This area should
#       probably be re-thought, as it isn't not easy to understand.
if [ -z "$blueprint" ] || [ -z "$destname" ];then
  echo -e "Must pass blueprint name and destname as last 2 positional args"
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
run_generate_new_script

# Exit Successfully 
exit_with_code $EXIT_OK


################################################################################
####
####   "Will-Change"
####    >-  $NEW_TEMPLATES_DIR will be a "default" value which shall easily   
####        be overwritten by any number of configuration files located in  
####        the users $HOME_DIR or project folders.
####
####    >-  Somehow variables will be available for use inside templates. This
####        feature requires some thought since "new"/blueprints must work for
####		    all file types, so it must be careful about how it chooses to identify
####        variables intented to be templated and boilerplate with similar syntax 
####        that is just meant to be part of the template. (perhaps the variables
####        will be explict mappings between search and replace values)
####        
####    >-  There will be a restore. The backup is already done.        
####        
####

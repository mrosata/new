#!/bin/bash

################################################################################
####
####   "New"
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


# Save the path the user is running the script from.
USERSPATH=`pwd`
# push the directory this script is in to the dir stack
pushd `dirname $0` > /dev/null
# Save the path the script is running from
SCRIPTPATH=`pwd`
# Put the world back to normal
popd > /dev/null

local_config_file=
# Source a local config file if exists
if [ -f "$USERSPATH/.new-conf" ];then

  # FIRST CHECK IN USERS CURRENT PATH
  local_config_file="$USERSPATH/.new-conf"
  . "$local_config_file"
  local_backups_dir="${backups:-}"
  local_templates_dir="${blueprints:-}"
  if [ -n "$local_templates_dir" ];then
    local_templates_dir="$USERSPATH/$local_templates_dir"
  fi
  if [ -n "$local_backups_dir" ];then
    local_backups_dir="$USERSPATH/$local_backups_dir"
  fi
  # Unset these because they should be replaced by the global config
  # and if there is no global config it would cause confusion.
  unset backups
  unset blueprints
fi

# Source the main config file (from bin)
if [ ! -f "$SCRIPTPATH/.new-conf" ];then

  echo "No global config file, run ./install.sh"
  exit;
fi


NEW_IMPORTS_DIR="$SCRIPTPATH/bin"
NEW_TEMPLATES_DIR="${blueprints:-$SCRIPTPATH/blueprints}"
NEW_BACKUP_DIR="${backups:-$SCRIPTPATH/.backups}"


function run_create_new_script() 
  { . "$NEW_IMPORTS_DIR/create-new"; }

function run_destroy_script()
  { . "$NEW_IMPORTS_DIR/destroy-new"; }

function run_generate_new_script ()
  { . "$NEW_IMPORTS_DIR/generate-new"; }

function run_usage_info_help_script ()
  { . "$NEW_IMPORTS_DIR/funcs-usage-info"; }

function run_bash_utils_script ()
  { . "$NEW_IMPORTS_DIR/bash-utilities"; }

function load_exit_code_script ()
  { . "$NEW_IMPORTS_DIR/exit-code-util"; }


################################################################################
####
####   "Usage"
####      

run_usage_info_help_script


################################################################################
####
####  "Source Scripts"
####

run_bash_utils_script

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
####     E_OPTERR    ->  42  -->  "Invalid Argument"
####

load_exit_code_script

################################################################################
####
####   "Options"
####
####      -t DIRECTORY  - "target - Target directory, defaults to current."
####      -v            - "verbose - display what changes will be made."
####	    -n            - "Set the newname option on the fly"
####      -f            - "Folders - show the folder locations"
####      -b            - "Backup folder" - default to $SCRIPTPATH/backups
####      -B            - "No backups" - default is to create backups
####      -e            - "Edit on create" - use flag to edit new blueprint
####      -x            - "Explicit extension" - create/generate extension
####      -p            - "Explicit newpath" - create/generate newpath
####      -a            - "Explicit after" - create/generate after
####

# Arguments
CREATE_NEW=0
ENFORCE_GLOBAL=0
EDIT_ON_CREATE=0
DESTROY_TEMPLATE=0
TARGET_DIR=$(pwd)
UNKNOWN_ARG=0       # This turns to 1 if unknown arg is passed.
NO_BACKUPS=0
VERBOSE=0
INFER_NEWPATH=0
FORCE_DIRECTORIES=


# Check if user passed -h|help -l|list or info
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
while getopts "t:b:x:p:a:n:hvfbdBeg!" opt
do
  case $opt in
    # Set the newname property.
  	n)
      EXPLICIT_NEWNAME="$OPTARG"
      add_verbose_msg "setting 'newname' to $OPTARG"
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
    d)
      FORCE_DIRECTORIES=1
      ;;
    # Set target directory (optional)
    t)
      TARGET_DIR="$OPTARG"
      add_verbose_msg "set target dir to $TARGET_DIR"
      ;;
    # Set backup directory (optional)
    b)
      NEW_BACKUP_DIR="$OPTARG"
      add_verbose_msg "set backup directory: \e[1m $NEW_BACKUP_DIR\e[21m"
      ;;
    B)
      NO_BACKUPS=1
      add_verbose_msg "run will not create any backup"
      ;;
    e)
      EDIT_ON_CREATE=1
      add_verbose_msg "will edit template file (if in 'new' mode)"
      ;;
    x)
      EXPLICIT_EXTENSION="$OPTARG"
      add_verbose_msg "using explicit extension:\e[1m $OPTARG\e[21m"
      ;;
    p)
      if [ -n "$OPTARG" ];then
        EXPLICIT_NEWPATH="$OPTARG"
        add_verbose_msg "using explicit newpath:\e[1m $OPTARG\e[21m"
      else
        # TODO: This option will try to figure out the path to either save
        #       to a blueprint .new-conf or to use in generating one.
        INFER_NEWPATH=1
        # add_verbose_msg "will attempt to infer newpath if creating new blueprint"
      fi
      ;;
    a)
      EXPLICIT_AFTER="$OPTARG"
      add_verbose_msg "using explicit after:\e[1m $OPTARG\e[21m"
      ;;
    g)
      ENFORCE_GLOBAL=1
      add_verbose_msg "enforcing \e[1mglobal\e[21m configuration"
      ;;
    # Invalid Arguments. Display if verbose
    \?)
      UNKNOWN_ARG=1
      add_verbose_msg "unknown argument: -$opt \e[1m$OPTARG\e[21m"
      ;;
  esac
done

# Check for 2 positional args: template and destination filename
blueprint=${@:$OPTIND:1}
destname=${@:$OPTIND+1:1}

if [ "1" -eq "$EDIT_ON_CREATE" ] && [ "0" -eq "$CREATE_NEW" ];then

  # This is a pure edit, not create and edit
  file_to_edit=${destname:-.new-conf}

  if [ "$ENFORCE_GLOBAL" -eq "0" ] && [ -f "$local_templates_dir/$blueprint/$file_to_edit" ];then
    # EDIT LOCAL TEMPLATE FILE.
    $EDITOR "$local_templates_dir/$blueprint/$file_to_edit";
    exit_with_code $EXIT_OK;
  elif [ -f "$NEW_TEMPLATES_DIR/$blueprint/$file_to_edit" ];then
    #EDIT GLOBAL TEMPLATE FILE
    $EDITOR "$NEW_TEMPLATES_DIR/$blueprint/$file_to_edit";
    exit_with_code $EXIT_OK;
  else
    add_verbose_msg "Can't find file $NEW_TEMPLATES_DIR/$blueprint/$file_to_edit"
    exit_with_code $E_NAMERR
  fi
fi



# Exit from unknown only after all args passed.
if [ "$UNKNOWN_ARG" -gt "0" ];then
  exit_with_code $E_OPTERR
fi


# NOTE: This test should only be reached if there isn't some pre-argument
#       commands run such as `new`, `destroy` or `edit`. This area should
#       probably be re-thought, as it isn't not easy to understand.
if [ "$CREATE_NEW" -eq "0" ] && [ "$DESTROY_TEMPLATE" -eq "0" ];then
  if [ -z "$blueprint" ] || [ -z "$destname" ];then
    echo -e "Must pass blueprint name and destname as last 2 positional args"
  fi
fi


# Now that we have arguments, it is time to build those arguments
# into folders and filenames to look up information required to 
# do the read and write.

if [ "$ENFORCE_GLOBAL" -eq "0" ] && [ -d "$local_templates_dir" ];then
  # Check if local template folder exists
  blueprint_folder="$local_templates_dir/$blueprint"
  blueprint_config="$blueprint_folder/.new-conf"
  # running mode helps in cli info and the generating backups
  running_mode="local"

  if [ "$CREATE_NEW" -eq "1" ] && [ -d "$local_templates_dir" ];then
    run_create_new_script
    exit_with_code $EXIT_OK
  elif [ "$DESTROY_TEMPLATE" -eq "1" ] && [ -d "$blueprint_folder" ];then
    run_destroy_script
    exit_with_code $EXIT_OK
  fi


  if [ ! -f "$blueprint_config" ];then
    add_verbose_msg "no config inside local boilerplate \"$blueprint\" in folder\e[1m $blueprint_folder\e[21m"
    unset blueprint_folder
    unset blueprint_config
    unset blueprint_force
  fi

fi


if [ ! -d "$blueprint_folder" ] || [ ! -f "$blueprint_config" ];then
  # Check that template folder exists.
  blueprint_folder="$NEW_TEMPLATES_DIR/$blueprint"
  blueprint_config="$blueprint_folder/.new-conf"
  # running mode helps in the generating backups
  running_mode="global"

  if [ "$CREATE_NEW" -eq "1" ]
    then
      run_create_new_script
      exit_with_code $EXIT_OK

  elif [ "$DESTROY_TEMPLATE" -eq "1" ]
    then
      run_destroy_script
      exit_with_code $EXIT_OK
  fi
fi


if [ ! -d "$blueprint_folder" ] || [ ! -f "$blueprint_config" ];then
  add_verbose_msg "new template $blueprint does not exists in folder $blueprint_folder"
  exit_with_code $E_TMPERR
fi

# Generate the boilerplate code
run_generate_new_script

# Exit Successfully 
exit_with_code $EXIT_OK



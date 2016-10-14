#!/bin/bash

################################################################################
####
####   bin/install.sh
####     @package: "Blueprints"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   This file is used to install and setup the "new" program.
####

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Create the configuration file if not exists
if [ ! -f "$SCRIPTPATH/.new-conf" ];then
  touch "$SCRIPTPATH/.new-conf"
  echo "blueprints=blueprints" >> "$SCRIPTPATH/.new-conf"
  echo "backups=.backups" >> "$SCRIPTPATH/.new-conf"
  exit;
fi

# source the config so we can build off it
. "$SCRIPTPATH/.new-conf"

# Create the backup directory if it doesn't exist.
NEW_BACKUP_DIR="${backups:-$SCRIPTPATH/.backups}"
if [ ! -d "$NEW_BACKUP_DIR" ];then
  echo -e "\n  - Creating directory for backups at: "
  echo -e "     $NEW_BACKUP_DIR"
  mkdir $NEW_BACKUP_DIR
else
  echo -e "\n  - Backups directory OK: "
  echo -e "     $NEW_BACKUP_DIR"
fi

# Create the templates directory if it doesn't exist
NEW_TEMPLATES_DIR="${blueprints:-$SCRIPTPATH/blueprints}"
if [ ! -d "$NEW_TEMPLATES_DIR" ];then
  echo -e "\n  Creating directory for templates at: "
  echo -e "     $NEW_TEMPLATES_DIR"
  mkdir "$NEW_TEMPLATES_DIR"
else
  echo -e "\n  - Templates directory OK: "
  echo -e "     $NEW_TEMPLATES_DIR"
fi

# Make sure that the main file is executable
if [ ! -x "$SCRIPTPATH/blueprints.sh" ];then
  chmod +x "$SCRIPTPATH/blueprints.sh"
  chmod 744 -R "$SCRIPTPATH/bin"
else
  echo -e "\n  - $SCRIPTPATH/blueprints.sh executable OK"
fi


function add_alias_to_config () {
  if [ -f "$1" ];then
    if `grep -Fxq "alias new=\"$SCRIPTPATH/blueprints.sh\"" "$1"`;then
      echo -e "\n  - Alias to executable blueprints.sh in $1 OK"
      echo -e "    use the alias \`new\` to run the program"
    else
    
    # Ask user if they want the alias in their config file.
    echo -e "\n  Would you like an alias to \`new\` inside your $1"
    echo -ne "    - type y/n then [ENTER]: "
    read answer

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ];then
      (
        # Add the alias to config file
        echo -e "\n\n### Program \"new\" alias:\nalias new=\"$SCRIPTPATH/blueprints.sh\"\n" \
            >> "$1"
        echo -e "    Restart shell or source file $1"
        echo -e "    use the alias \`new\` to run the program"
      )
    elif [ "$answer" != "n" ] && [ "$answer" != "N" ];then
      echo -e "  ! Please Respond either \"y\" or \"n\" (case insensitive)."
      add_alias_to_config "$1"
    fi
    fi
  fi
}


add_alias_to_config "$HOME/.bashrc"
add_alias_to_config "$HOME/.zshenv"
add_alias_to_config "$HOME/.zshrc"

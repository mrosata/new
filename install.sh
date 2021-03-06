#!/bin/bash

################################################################################
####
####   bin/install.sh
####     @package: "New"
####     @author: mrosata
####     @date:   10-2016
####     @desc:   This file is used to install and setup the "new" program.
####

# Quicknap makes the install pause for quick moments between steps. It's for 
# the users sake, so the text doesn't just appear all at once and they can
# intuitively feel the steps the install takes. Otherwise it is jarring to 
# answer a question prompt and instantly jump down 10 lines. 
function quicknap() {
  sleep_time="${1:-.2}"
  sleep $sleep_time
}


pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Create the configuration file if not exists
if [ ! -f "$SCRIPTPATH/.new-conf" ];then
  touch "$SCRIPTPATH/.new-conf"
  echo "blueprints=$SCRIPTPATH/blueprints" >> "$SCRIPTPATH/.new-conf"
  echo "backups=$SCRIPTPATH/.backups" >> "$SCRIPTPATH/.new-conf"
fi

# source the config so we can build off it
. "$SCRIPTPATH/.new-conf"

quicknap
# Create the backup directory if it doesn't exist.
NEW_BACKUP_DIR="${backups:-$SCRIPTPATH/.backups}"
if [ ! -d "$NEW_BACKUP_DIR" ];then
  echo -e "\n  - \e[1mCreating directory for backups at:\e[21m "
  echo -e "     $NEW_BACKUP_DIR"
  mkdir $NEW_BACKUP_DIR
else
  echo -e "\n  - \e[1mBackups directory OK:\e[21m "
  echo -e "     $NEW_BACKUP_DIR"
fi

quicknap
# Create the templates directory if it doesn't exist
NEW_TEMPLATES_DIR="${blueprints:-$SCRIPTPATH/blueprints}"
if [ ! -d "$NEW_TEMPLATES_DIR" ];then
  echo -e "\n  \e[1mCreating directory for templates at:\e[21m "
  echo -e "     $NEW_TEMPLATES_DIR"
  mkdir "$NEW_TEMPLATES_DIR"
else
  echo -e "\n  - \e[1mTemplates directory OK:\e[21m "
  echo -e "     $NEW_TEMPLATES_DIR"
fi

quicknap
# Make sure that the main file is executable
if [ ! -x "$SCRIPTPATH/blueprints.sh" ];then
  chmod +x "$SCRIPTPATH/blueprints.sh"
  chmod 744 -R "$SCRIPTPATH/bin"
else
  echo -e "\n  - $SCRIPTPATH/blueprints.sh executable OK"
fi


function add_alias_to_config () {
  quicknap
  if [ -f "$1" ];then
    if `grep -Fxq "alias new=\"$SCRIPTPATH/blueprints.sh\"" "$1"`;then
      echo -e "\n  - \e[1mAlias to executable blueprints.sh in $1 OK\e[21m"
      echo -e "    use the alias \`new\` to run the program"
    else
    
    # Ask user if they want the alias in their config file.
    echo -e "\n  \e[1mWould you like an alias to \`new\` inside your $1\e[21m"
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
      echo -e "  \e[31m! Please Respond either \"y\" or \"n\" (case insensitive).\e[39m"
      add_alias_to_config "$1"
    fi
    fi
  fi
}


function add_autocompletions () {
  tmp_autocomplete="$SCRIPTPATH/bin/.tmp_autocomplete"
  echo -e "#!/bin/bash\n\nnew_script_path=$SCRIPTPATH" > $tmp_autocomplete;
  cat "$SCRIPTPATH/bin/autocompletions" >> $tmp_autocomplete;

  if [ -d "/etc/bash_completion.d" ];then
    echo "Creating Autocompletions for Bash Shell"
    sudo cp -T "$tmp_autocomplete" "/etc/bash_completion.d/new_autocompletions"    
  fi
}


add_alias_to_config "$HOME/.bashrc"
add_alias_to_config "$HOME/.profile"
add_alias_to_config "$HOME/.zshenv"
add_alias_to_config "$HOME/.zshrc"
add_autocompletions

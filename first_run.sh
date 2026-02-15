#!/bin/bash
# ========================================================
# Termux Alias Setup Script
# This script helps you easily manage aliases in Termux.
# It adds aliases to the global bash.bashrc file if not already present.
# ========================================================


# ========================================================
# neofetch clone in Bash
# ========================================================


neofetch_clone() {
	# Colors
	RED="\033[31m"
	GREEN="\033[32m"
	YELLOW="\033[33m"
	BLUE="\033[34m"
	RESET="\033[0m"
	
	# Fetch info
	USER_NAME=$(whoami)
	HOST_NAME=$(hostname)
	OS_NAME=$(uname -o)
	KERNEL=$(uname -r)
	CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
	RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
	UPTIME=$(uptime -p)
	
	# Print custom info
	echo -e "${GREEN}User:${RESET} $USER_NAME"
	echo -e "${BLUE}Host:${RESET} $HOST_NAME"
	echo -e "${YELLOW}OS:${RESET} $OS_NAME"
	echo -e "${RED}Kernel:${RESET} $KERNEL"
	echo -e "${BLUE}CPU:${RESET} $CPU"
	echo -e "${GREEN}RAM:${RESET} $RAM_TOTAL"
	echo -e "${YELLOW}Uptime:${RESET} $UPTIME"


}


# Path to the global bash configuration file in Termux
FILE="/data/data/com.termux/files/usr/etc/bash.bashrc"

# --------------------------------------------------------
# Function: add_alias
# Purpose : Adds an alias or any command line to bash.bashrc
# Input   : A single string representing the alias/command
# Behavior: 
#   - Checks if the line already exists in the file
#   - If not, appends it
#   - Provides feedback in the terminal
# --------------------------------------------------------
add_alias() {
  local ALIAS_LINE="$1"  # store input line
  # grep checks exact match (-x), quietly (-q), fixed string (-F)
  if ! grep -qxF "$ALIAS_LINE" "$FILE"; then
    echo "$ALIAS_LINE" >> "$FILE"  # append if not present
    echo "✅ Added: $ALIAS_LINE"
  else
    echo "⚡ Already exists: $ALIAS_LINE"
  fi
}

# --------------------------------------------------------
# Add first-run script auto-source
# Purpose: Ensures your first_run.sh executes every new Termux session
# --------------------------------------------------------
add_alias "source /data/data/com.termux/files/home/MY_GIT/termux_basic/first_run.sh"


# --------------------------------------------------------
# Function: fix_update_alias
# Purpose : Update your local termux_basic repository from Git
#           and reload aliases or environment
# --------------------------------------------------------
fixu_update_alias() {
    # Move to the termux_basic repository directory
    cd "$HOME/MY_GIT/termux_basic/" || {
        echo "❌ Directory not found: $HOME/MY_GIT/termux_basic/"
        return 1
    }

    # Pull the latest changes from the remote Git repository
    git pull

    # Reload aliases or environment after update
    # 'reset' clears terminal display but does not reload bashrc
    # If you want to reload aliases, you might want:
    # source /data/data/com.termux/files/usr/etc/bash.bashrc
    # reset
    cd $HOME
    # kill termux 
    exit
}

# --------------------------------------------------------
# Basic aliases
# --------------------------------------------------------
alias myedit='nano /data/data/com.termux/files/usr/etc/bash.bashrc'  # edit bashrc quickly
alias cls='clear'  # clear terminal screen

# --------------------------------------------------------
# Git related aliases
# --------------------------------------------------------
alias gitp='git pull'  # shortcut for git pull
alias gitwho='git remote -v'  # list git remote URLs

# --------------------------------------------------------
# Bash management alias
# --------------------------------------------------------
# alias bash_reset='source /data/data/com.termux/files/usr/etc/bash.bashrc'  
# allows manual reload of bash.bashrc after changes

# --------------------------------------------------------
# Test alias
# --------------------------------------------------------
alias test='seq 1 10'  # prints numbers 1 to 10 for testing purposes

# --------------------------------------------------------
# Notes:
# 1. Running this script once will ensure the first_run.sh is sourced in every new shell.
# 2. The add_alias function avoids duplicate entries.
# 3. You can manually add more aliases by either:
#    - Using add_alias "alias ..." inside this script
#    - Or directly editing bash.bashrc
# 4. After editing or adding aliases, run `source /data/data/com.termux/files/usr/etc/bash.bashrc` 
#    or restart Termux to apply changes.
# 5. first_run.sh should not override your other aliases unless intentional.
# ========================================================





print_face() {


    # Define an array of colors
    COLORS=("\e[31m" "\e[32m" "\e[33m" "\e[34m" "\e[35m" "\e[36m")
    
    # Pick a random color from the array
    RANDOM_COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}

    echo -e "${RANDOM_COLOR}⠀⠀⠀⣿⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\e[0m" # Green
    echo -e "${RANDOM_COLOR}⠀⠀⢀⣿⣿⣿⣿⣿⣿⣆⡀⠀⠀⠀⠀⣠⣴⣦⡄⢤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣷⣶⣶⣿⣿⣿⣿⡀⣽⡿⣶⣦⡀⠀⠀⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡿⣿⣿⣿⣿⣆⠀⠀⠀⠀\e[0m" # Red
    echo -e "${RANDOM_COLOR}⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣦⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣟⣿⣿⣿⣿⣿⡿⢟⣿⣷⡀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣭⣿⣿⣽⣿⣽⣾⣿⣿⣿⠛⠉⠉⠀⢈⣿⣿⡇⠀\e[0m" # White
    echo -e "${RANDOM_COLOR}⠀⠀⠀⢻⣿⣿⠛⠉⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠡⠤⠄⠁⠀⠀⢻⣿⡇⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠘⣿⣿⠄⠀⠀⠀⠀⠀⣉⠙⠋⢿⣿⣯⠀⠀⠀⠀⠀⠀⣰⣿⣿⡿⡃⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⢹⣿⣇⣀⠀⠈⠉⠉⠁⠀⣤⢠⣿⣿⣧⡆⣤⣤⡀⣾⣿⣿⣿⢠⡇⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⣿⣿⣿⣷⣤⠄⣀⣴⣧⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⠇⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠸⣿⣯⠉⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⡯⠁⡌⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠙⢿⡄⢿⣿⣿⣿⣿⣿⣎⠙⠻⠛⣁⣼⣿⣿⡿⠛⠁⡸⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠀⠈⢿⡄⠉⣿⡿⣿⣿⣿⣿⣷⣬⣿⡿⠟⠋⢀⣴⡞⠁⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⠀⠀⠀⠀⠉⠉⠋⠉⠉⠁⠀⢀⣴⣿⡿⠀⠀⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⠿⢃⣴⣿⣿⣿⠃⠀⠀⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀\e[0m"
    echo -e "${RANDOM_COLOR}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀\e[0m"
    echo -e "\e[33mAnd Here We Go\e[0m" # Yellow text for the phrase
}

print_info() {

    # -------- Info Section --------
    echo -e "\e[36m==============================================\e[0m" # cyan line
    echo -e "\e[32mPublic Research Association of Social Hacktivity\e[0m" # green
    echo -e "\e[33mLocation: Trichy\e[0m" # yellow
    echo -e "\e[35mAdmin: https://github.com/Tpj-root\e[0m" # magenta
    echo -e "\e[36mVersion: 1.0\e[0m" # cyan
    echo -e "\e[36m==============================================\e[0m" # cyan line

}

clear
neofetch
print_face
print_info


# install_missing_packages
# --------------------------------------------------------
alias fixp_missing_packages='bash /data/data/com.termux/files/home/MY_GIT/termux_basic/basic_software_install.sh' #



# python ✅ Serves current directory
alias fixs_python_server='python3 -m http.server 8080'
alias fixe_exit='exit'
alias pyhttp='python -m http.server 8000'


#
# Fix runtime errors
#

killhttp() {

    # ps aux
    # ps  = show running processes
    # a   = show processes of all users
    # u   = show detailed info (user, PID, CPU, etc.)
    # x   = include processes not attached to terminal
    #
    # grep "http.server"
    # Filters only lines containing http.server
    #
    # grep -v grep
    # Removes the grep command itself from results
    #
    # awk '{print $2}'
    # awk extracts the 2nd column → PID (Process ID)

    pid=$(ps aux | grep "http.server" | grep -v grep | awk '{print $2}')

    # -z "$pid"
    # Checks if variable is empty
    # If empty → no server running

    if [ -z "$pid" ]; then
        echo "No http.server running"
    else
        echo "Killing PID: $pid"

        # kill -9
        # -9 = force kill (SIGKILL)
        # Immediately stops the process

        kill -9 $pid
    fi
}


alias fixkill_pyhttp='killhttp'

fixfilm_server() {

    # Port number where the HTTP server will run
    PORT=8000

    # Directory path where your film files are stored
    # $HOME = your home directory
    DIR="$HOME/storage/downloads/film"

    # Find if any process is already using this PORT
    # lsof -ti :$PORT
    # -lsof = list open files (network ports are files)
    # -t = show only PID
    # -i :$PORT = filter by this port number
    PID=$(lsof -ti :$PORT)

    # If PID is not empty, that means server already running
    if [ -n "$PID" ]; then
        echo "Killing old server (PID: $PID)"

        # kill -9 force stops the process immediately
        kill -9 $PID
    fi

    # Change directory to your film folder
    # If folder not found, show message and stop function
    cd "$DIR" || { echo "Folder not found"; return 1; }

    # Start Python HTTP server on selected PORT
    echo "Starting server on port $PORT..."

    # python3 -m http.server runs built-in simple web server
    python3 -m http.server $PORT
}


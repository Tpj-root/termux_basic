#!/bin/bash
# ========================================================
# Termux Alias Setup Script
# This script helps you easily manage aliases in Termux.
# It adds aliases to the global bash.bashrc file if not already present.
# ========================================================

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


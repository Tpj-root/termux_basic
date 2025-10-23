#!/bin/bash
# add aliases to bash.bashrc easily

FILE="/data/data/com.termux/files/usr/etc/bash.bashrc"

add_alias() {
  local ALIAS_LINE="$1"
  if ! grep -qxF "$ALIAS_LINE" "$FILE"; then
    echo "$ALIAS_LINE" >> "$FILE"
    echo "✅ Added: $ALIAS_LINE"
  else
    echo "⚡ Already exists: $ALIAS_LINE"
  fi
}


add_alias "source /data/data/com.termux/files/home/MY_GIT/termux_basic/first_run.sh"


# example alias basic
alias myedit='nano /data/data/com.termux/files/usr/etc/bash.bashrc'
alias cls='clear'

# later you can just add more aliases like:
# alias ll='ls -la'"
# alias gs='git status'"



# git alias
alias gitp='git pull'
alias gitwho='git remote -v'


#
alias bash_reset='source /data/data/com.termux/files/usr/etc/bash.bashrc'
# 
# auto reset not work
# source /data/data/com.termux/files/usr/etc/bash.bashrc
# for test
alias test1='seq 1 10'



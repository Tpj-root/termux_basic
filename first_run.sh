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

# example alias basic
add_alias "alias myedit='nano /data/data/com.termux/files/usr/etc/bash.bashrc'"
add_alias "alias cls='clear'"

# later you can just add more aliases like:
# add_alias "alias ll='ls -la'"
# add_alias "alias gs='git status'"



# git alias
add_alias "alias gitp='git pull'"
add_alias "alias gitwho='git remote -v'"


#
add_alias "alias bash_reset='source /data/data/com.termux/files/usr/etc/bash.bashrc'"
# 
# auto reset not work
# source /data/data/com.termux/files/usr/etc/bash.bashrc

# for test
add_alias "alias test1='seq 1 10'"

add_alias "alias bash_run='bash /data/data/com.termux/files/home/MY_GIT/first_run.sh'"

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

# example alias
add_alias "alias edit='nano /data/data/com.termux/files/usr/etc/bash.bashrc'"

# later you can just add more aliases like:
# add_alias "alias ll='ls -la'"
# add_alias "alias gs='git status'"




# git alias
add_alias "alias gitp='git pull'"
add_alias "alias gitwho='git remote -v'"





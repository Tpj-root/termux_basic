#!/bin/bash
# ========================================================
# Termux Package Checker & Auto Installer
# This script checks for required software in Termux (or Linux)
# and installs any missing packages automatically.
# ========================================================

# --------------------------------------------------------
# Function: install_missing_packages
# Purpose : Checks a predefined list of software and installs
#           missing ones using pkg, apt, or pacman.
# Input   : SOFTWARE_LIST array defined by user
# Behavior:
#   - Detects available package manager (pkg/apt/pacman)
#   - Checks each software using `command -v`
#   - Installs only those not found
#   - Optionally runs inside a tmux session (`intermux`)
# --------------------------------------------------------

# put this in your ~/.bashrc or functions.sh and source it



# # Basic essentials
# pkg install git curl wget nano vim python clang make

# # Network & web tools
# pkg install nmap net-tools openssh socat iproute2

# # Compression & file tools
# pkg install zip unzip tar p7zip

# # Development & build tools
# pkg install cmake nodejs golang rust

# # Text & JSON tools
# pkg install jq grep sed awk coreutils

# # Security / pentesting tools
# pkg install hydra hashcat sqlmap metasploit

# # Terminal utilities
# pkg install tmux htop neofetch termux-api

# # Wordlist / brute-force tools
# pkg install crunch

# # Extra utilities
# pkg install ffmpeg imagemagick proot fish zsh




SOFTWARE_LIST=(crunch cmake curl sl python openssh neofetch)




install_missing_packages() {
  local run_in_tmux=${RUN_IN_TMUX:-0}
  local installer=""
  if command -v pkg >/dev/null 2>&1; then
    installer="pkg"
  elif command -v apt >/dev/null 2>&1 || command -v apt-get >/dev/null 2>&1; then
    installer="apt"
  elif command -v pacman >/dev/null 2>&1; then
    installer="pacman"
  else
    echo "No supported installer (pkg/apt/pacman) found on PATH." >&2
    return 2
  fi

  _install_one() {
    local p=$1
    if command -v "$p" >/dev/null 2>&1; then
      echo "$p: already installed"
      return 0
    fi
    echo "$p: NOT found — installing..."
    case "$installer" in
      pkg) pkg install -y "$p" ;;
      apt) sudo apt-get update && sudo apt-get install -y "$p" ;;
      pacman) sudo pacman -Sy --noconfirm "$p" ;;
    esac
    if command -v "$p" >/dev/null 2>&1; then
      echo "$p: installed OK"
      return 0
    else
      echo "$p: install FAILED" >&2
      return 1
    fi
  }

  run_installs() {
    local fail=0
    for pkg in "${SOFTWARE_LIST[@]}"; do
      _install_one "$pkg" || fail=1
    done
    return $fail
  }

  if [ "$run_in_tmux" -eq 1 ] && command -v tmux >/dev/null 2>&1; then
    echo "Starting tmux session 'intermux' to run installs..."
    tmux new-session -d -s intermux "bash -lc 'run_installs; echo \"install finished (status \$?)\"; exec bash'"
    echo "Attach with: tmux attach -t intermux"
  else
    run_installs
  fi
}


install_missing_packages








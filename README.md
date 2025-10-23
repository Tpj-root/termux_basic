# termux_basic




# Update & upgrade packages
pkg update && pkg upgrade

# Install basic tools
pkg install git curl wget nano python vim clang make

# File operations
ls          # list files
cd <dir>    # change directory
pwd         # show current path
cp a b      # copy file
mv a b      # move/rename file
rm a        # delete file
mkdir new   # make directory
rmdir old   # remove directory

# Package management
pkg search <name>   # search package
pkg install <name>  # install package
pkg uninstall <name> # remove package
pkg list-installed  # list installed packages

# Git usage
git clone <repo_url>
git pull
git status

# Python use
python
python script.py

# System info
uname -a
top
df -h
whoami

# Exit Termux
exit




env: This command displays all currently set environment variables. 
printenv
printenv HOME

echo $PATH
    
add permanent alias


alias edit ='nano /data/data/com.termux/files/usr/etc/bash.bashrc'


#!/bin/bash
# Assumes "provision.sh" has already been run for prereqs to have been installed
#
# This script deals with things that cannot be installed with vagrant's default "sudo"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Oddly the vagrant user doesn't own it's own home folder (which causes issues when
# things don't have permission to create folders etc) - there may be a more official
# vagrant-y solution as this seems hacky
# This specifically is to be able to install the awscli
echo "Updating folder permissions ..."
sudo chown vagrant /home/vagrant -R
sudo chgrp vagrant /home/vagrant -R

ls -l /home

echo "Installing tools (no sudo) ..."

printf "${NC}> %-20s -> " "awscli"
if pip install awscli -q --upgrade --user; then
  echo "PATH=~/.local/bin:${PATH}" >> .bashrc
  printf "${GREEN}$(aws --version 2>&1)\n"
else
    printf "${RED}failed to install !!\n"
fi


#!/bin/bash
# Assumes "provision.sh" has already been run for prereqs to have been installed
#
# This script deals with things that cannot be installed with vagrant's default "sudo"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "Installing tools (no sudo) ..."

printf "${NC}> %-20s -> " "awscli"
if pip install awscli -q --upgrade --user; then
  echo "PATH=~/.local/bin:${PATH}" >> .bashrc
  printf "${GREEN}$(aws --version 2>&1)\n"
else
    printf "${RED}failed to install !!\n"
fi


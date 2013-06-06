#!/bin/bash -e
export TERM=xterm-256color 
source "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.9.2@unix_cli

#
# Update everything
#
git checkout develop
git pull origin develop
bundle update

bash ./jenkins/latest.sh

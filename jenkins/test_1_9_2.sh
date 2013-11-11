#!/bin/bash -e
export TERM=xterm-256color 
source "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.9.3@unix_cli
gem install bundler

git checkout develop
git pull
bundle install
bundle update
rake spec:unit
rake jenkins:spec

#!/bin/bash -e
export TERM=xterm-256color 
source "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.9.2@unix_cli

git checkout develop
git pull

yes | bundle install
bundle update
rm -f hpcloud-*.gem
gem build hpcloud.gemspec
gem install hpcloud-*.gem

bash ./jenkins/notes.sh
bash ./jenkins/reference.sh
bash ./jenkins/drupal.sh

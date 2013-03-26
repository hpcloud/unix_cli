#!/bin/sh
echo '**** Starting Create Unix CLI Server ****'
cat >/etc/motd.tail <<!
####################################################
Unix CLI Server
####################################################
!
apt-get update
apt-get install -y ruby1.8 ruby-dev
apt-get install -y rubygems
apt-get install -y libxml2 libxml2-dev libxslt1-dev libxslt1.1 sgml-base xml-core
gem install rdoc
curl -sL https://docs.hpcloud.com/file/hpfog.gem >hpfog.gem
gem install --no-rdoc hpfog.gem
curl -sL https://docs.hpcloud.com/file/hpcloud.gem >hpcloud.gem
sudo gem install --no-rdoc hpcloud.gem
echo '**** Finished Create Unix CLI Server ****'

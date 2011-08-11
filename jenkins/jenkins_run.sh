#!/bin/bash -x
bundle install
# bundle update fog
rake jenkins:spec
# make exit status explicit for debugging purposes
last_status=$?
echo $last_status
exit $last_status
#! /bin/bash

. $RVM_SCRIPT
rvm use $TEST_RUBY
rvm --force gemset delete $TEST_GEMSET
rvm gemset create $TEST_GEMSET
rvm gemset use $TEST_GEMSET

bundle install
rake test

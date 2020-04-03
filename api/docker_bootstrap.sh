#!/bin/bash


bundle exec rake db:create
bundle exec rake db:migrate

rm -f tmp/pids/server.pid 
bundle exec rails s -p $PORT -b '0.0.0.0'
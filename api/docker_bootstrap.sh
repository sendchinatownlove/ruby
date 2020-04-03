#!/bin/bash


# bundle exec rake db:create
# bundle exec rake db:migrate
rake db:migrate 2>/dev/null || rake db:setup

rm -f tmp/pids/server.pid 
bundle exec rails s -p $PORT -b '0.0.0.0'
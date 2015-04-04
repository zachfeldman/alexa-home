#!/bin/bash

cd $ALEXA_HOME
cd server
bundle exec ruby app.rb &
cd ..
cd scraper
bundle exec ruby watir-login.rb &

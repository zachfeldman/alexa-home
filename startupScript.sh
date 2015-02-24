#!/bin/bash

source ~/.env
cd $ALEXA_HOME
bundle exec ruby app.rb &
bundle exec ruby watir-login.rb &

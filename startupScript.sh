#!/bin/bash

cd /home/pi/dev/alexa-home
source ~/.env
bundle exec ruby app.rb &
bundle exec ruby watir-login.rb &

#!/bin/bash

cd /home/pi/dev/alexa-home
bundle exec ruby app.rb &
bundle exec ruby watir-login.rb &

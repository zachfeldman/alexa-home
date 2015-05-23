# Getting Started

You'll need to set some environment variables. If you don't know what that means, check out [Using Environment Variables to Safely Store API Credentials](http://blog.zfeldman.com/2014-04-07-Using-Environment-Variables-to-Safely-Store-API-Credentials). See `sample-dot-env` for a list of which environment variable to set.

1) Clone this repository (see the link on the right) or download it as a zip file. We recommend putting it in the folder `~/dev/alexa-home`.

2) Open up the directory in your terminal application by dragging it into Terminal from the Finder or using the `cd` (change directory) command, I.E. `cd /home/pi/dev/alexa-home`

3) Run `bundle install` (I'm assuming you have Ruby 2.0+, using `ruby -v` to find out, if not try rbenv or rvm to upgrade) in both the `scraper` and `server` directories.

4) If you plan on using a Hue setup, press the button on top of your Hue unit

5) If you don't want to use all of the existing modules, edit `modules.yml` and comment out or remove modules. You may have issues loading the server if you load modules you don't have credentials set for or haven't activated, like loading the Hue module which requires you to press the button on the top of your Hue hub. Obviously if you don't have a hue, comment out this module on `modules.yml`.

5) The repository includes two components: a web scraper to get commands from Amazon Echo history (`watir-login.rb`) and a Sinatra server that takes those commands and, using various modules, triggers certain actions. Type `chmod +x startScript.sh && ./startupScript.sh` to start both of these parts in the background.

6) This will start Alexa Home in the background. To stop Alexa Home, see "Stopping Alexa Home"

# Alexa Home

Welcome to Alexa Home! The goal of this project is to use your [Amazon Echo](http://amzn.to/1DO0ax3) to control various home automation software. Interested in integrating a new module? Check out some of the code and send in a pull request! Glad to help out.

Good demo video at [http://youtu.be/9AmxiGVBekE](http://youtu.be/9AmxiGVBekE)

Here's a blog post too with a bad demo video and some background:

[http://blog.zfeldman.com/2014-12-28-using-amazon-echo-to-control-lights-and-temperature](http://blog.zfeldman.com/2014-12-28-using-amazon-echo-to-control-lights-and-temperature)

## Setting up

You'll need to clone the repository from GitHub in the Terminal. I recommend putting it in the folder `~/dev/alexa-home`

You'll also need to set some environmental variables, which could be accomplished like this:

````bash
# in a file called .env, located at ~
# try vim ~/.env or nano ~/.env
export ALEXA_HOME=/path/to/alexa-home/repo

export NEST_EMAIL=your_nest_email@awesome.com
export NEST_PASS=your_nest_password_not_test123

export AMAZON_EMAIL=youramazonlogin
export AMAZON_PASSWORD=your_awesome_pass_not_12345
````

For more, check out [Using Environment Variables to Safely Store API Credentials](http://blog.zfeldman.com/2014-04-07-Using-Environment-Variables-to-Safely-Store-API-Credentials)(

## Getting Started

This has to be run on the same network your Hue is on, but not necessarily the same network your Echo is on.

1) Clone this repository (see the link on the right) or download it as a zip file.

2) Open up the directory in your terminal application by dragging it into Terminal from the Finder or using the `cd` (change directory) command, I.E. `cd /home/pi/dev/alexa-home`

3) Run `bundle install` (I'm assuming you have Ruby 2.0+, using `ruby -v` to find out, if not try rbenv or rvm to upgrade).

3) If you plan on using a Hue setup, press the button on top of your Hue unit

3) If you don't want to use all of the existing modules, edit `config.yml` and comment out or remove modules. Should look like this:

```
---

# this is a comment, only configuring hue and nest
modules:
  - hue
  - nest
```

4) Type `chmod +x startScript.sh && ./startupScript.sh`

5) This will start Alexa Home in the background. To stop Alexa Home, see "Stopping Alexa Home"

## Running automatically on a Rasperry Pi at boot

1) Edit the `autostart`file:
`sudo vim /etc/xdg/lxsession/LXDE-pi/autostart`

2) Add the following line:
`@bin/bash /homepi/dev/alexa-home/startupScript.sh`
at the bottom

3) Try it out by typing `startx`, or for real by typing `sudo reboot`

Note: Since you can't see the screen if starting a headless Pi: I have the first generation Pi and it takes about 3.5 minutes to start up and startup Iceweasel (the Echo proxy). I'd give it 5 minutes before worrying about troubleshooting your setup. Or just wait with a screen plugged in if you can.

## Existing Modules

1) Phillips Hue

2) Nest Thermostat

## Module Roadmap

I'd love to get these resolvers/modules done at some point too:

1) August Smart Lock

2) IR Transmitter to turn on and off the television

3) Uber to call a cab...with your voice!

## Stopping Alexa Home

1) Type `ps aux | grep ruby` at the Terminal to see a list of running Ruby processes

2) If you see the server (app.rb) or the Watir runner (watir-login.rb) and want to stop either of them, type `sudo kill -9 <PID>` , PID corresponding to the program's process ID.

## Contributors

[@zachfeldman](https://twitter.com/zachfeldman)

## Contributing

Send in pull requests!


## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.
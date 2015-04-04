# Running automatically on a Rasperry Pi at boot

1) Edit the `autostart`file:
`sudo vim /etc/xdg/lxsession/LXDE-pi/autostart`

2) Add the following line:
`@bin/bash /homepi/dev/alexa-home/startupScript.sh`
at the bottom

3) Try it out by typing `startx`, or for real by typing `sudo reboot`

Note: Since you can't see the screen if starting a headless Pi: I have the first generation Pi and it takes about 3.5 minutes to start up and startup Iceweasel (the Echo proxy). I'd give it 5 minutes before worrying about troubleshooting your setup. Or just wait with a screen plugged in if you can.
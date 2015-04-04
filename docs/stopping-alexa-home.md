# Stopping Alexa Home

1) Type `ps aux | grep ruby` at the Terminal to see a list of running Ruby processes

2) If you see the server (app.rb) or the Watir runner (watir-login.rb) and want to stop either of them, type `sudo kill -9 <PID>` , PID corresponding to the program's process ID.
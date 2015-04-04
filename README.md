# Alexa Home

Welcome to Alexa Home! The goal of this project is to use your [Amazon Echo](http://amzn.to/1DO0ax3) to control various home automation software. Interested in integrating a new module? Check out some of the code and send in a pull request! Glad to help out. 

The repository includes two components: a web scraper to get commands from Amazon Echo history (`watir-login.rb`) and a Sinatra server that takes those commands and, using various modules, triggers certain actions.

Good demo video at [http://youtu.be/9AmxiGVBekE](http://youtu.be/9AmxiGVBekE)

Here's a blog post too with a bad demo video and some background:

[http://blog.zfeldman.com/2014-12-28-using-amazon-echo-to-control-lights-and-temperature](http://blog.zfeldman.com/2014-12-28-using-amazon-echo-to-control-lights-and-temperature)


## Documentation

[Getting Started](docs/getting-started.md)

[Stopping Alexa Home services](docs/stopping-alexa-home.md)

[Running automatically on a Rasperry Pi at boot](docs/rasp-pi-autostart.md)


## Existing Modules

Here are the modules we have so far, would love some more! Docs for each as well if you click the link.

1) [Phillips Hue](docs/modules/hue.md)

2) [Nest Thermostat](docs/modules/nest.md)

3) [jRiver player](docs/modules/jriver.md)

4) [Uber](docs/modules/uber.md)

5) [Google Calendar](docs/modules/google_calendar.md)


## Contributors

- [@zachfeldman](https://twitter.com/zachfeldman) (Wrote majority of codebase, original idea)
- Steven Arkonovich (funded iRiver integration, wrote Google Calendar integration)


## Contributing

Send in pull requests! Please keep with the format that we have already re: modules, etc.


## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>.
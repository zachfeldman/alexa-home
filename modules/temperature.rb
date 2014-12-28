require 'nest_thermostat'

NEST_CLIENT = NestThermostat::Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'])

def process_temperature(command)
  words = command.split(" ")
  index = words.index("to")
  temp = (words[index + 1] + " " + words[index + 2]).in_numbers if !index.nil?

  NEST_CLIENT.temperature = temp
end
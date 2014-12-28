require 'nest_thermostat'

CLIENT = NestThermostat::Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'])

def process_temperature(command)
  words = command.split(" ")
  index = words.index("to")
  temp = words[index + 1].to_i if !index.nil?

  CLIENT.temperature = temp
end
require 'sinatra'
require 'yaml'

require './helpers'

modules = YAML.load_file('config.yml')['modules']
require './modules/lights' if modules.include? 'hue'
require './modules/temperature' if modules.include? 'nest'
require './modules/iRiver_player' if modules.include? 'iriver'
require './modules/uber' if modules.include? 'uber'

require 'numbers_in_words'
require 'numbers_in_words/duck_punch'

def process_query(command)
  # HUE LIGHTS #
  if command.scan(/light|lights/).length > 0
    process_lights(command)
  # NEST #
  elsif command.scan(/temperature|nest/).length > 0
    process_temperature(command)
  elsif command.scan(/river/).length > 0
    process_player(command, player: "iriver")
  elsif command.scan(/cab to/).length > 0
    process_uber(command)
  end
end

get '/command' do
  process_query(params[:q])
end

get '/status' do
  status 200
end

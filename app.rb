require 'sinatra'

require './modules/lights'
require './modules/temperature'

def process_query(command)
  # HUE LIGHTS #
  if command.scan(/light|lights/).length > 0
    process_lights(command)
  # NEST #
  elsif command.scan(/temperature|nest/).length > 0
    process_temperature(command)
  end
end

get '/command' do
  process_query(params[:q])
end
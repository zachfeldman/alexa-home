require 'sinatra'
require 'yaml'

require './helpers'

modules = YAML.load_file('modules.yml')['modules']
MODULE_INSTANCES = []
modules.each do |alexa_module|
  require "./modules/#{alexa_module}/module.rb"
end

get '/command' do
  MODULE_INSTANCES.each do |alexa_module|
    if params[:q].scan(Regexp.new(alexa_module.wake_words.join("|"))).length > 0
      alexa_module.process_command(params[:q])
    end
  end
  status 200
end

get '/status' do
  status 200
end
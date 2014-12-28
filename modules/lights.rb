require 'hue'
require './color'

CLIENT = Hue::Client.new

ZACH_ROOM_LIGHTS = ["bedside", "overhead"]

def light_command(lights, options = {})
  p options
  lights.each do |light|
    light.on = options[:on] if !options[:on].nil?
    light.set_state(options[:color]) if !options[:color].nil?
    sleep(0.5)
  end
end

def process_lights(command)
  lights_to_act_on = []
  
  # Select lights
  if command.scan(/all/).length > 0
    lights_to_act_on = CLIENT.lights
  elsif command.scan(/room/).length > 0
    lights_to_act_on = CLIENT.lights.select{|light| ZACH_ROOM_LIGHTS.include?(light.name.downcase)}
  else
    lights_to_act_on = CLIENT.lights.select{|light| command.split(" ").include?(light.name.downcase)}
  end

  # Set lighting options
  options = {}

  if command.scan(/on/).length > 0
    options[:on] = true
  elsif command.scan(/off/).length > 0
    options[:on] = false
  end

  words = command.split(" ")
  index = words.index("color")
  options[:color] = string_to_hue(words[index + 1]) if !index.nil?

  words = command.split(" ")
  index = words.index("brightness")
  if !index.nil?
    options[:color] = {} if !options[:color]
    options[:color][:bri] = words[index + 1].to_i
  end

  light_command(lights_to_act_on, options)
end
require 'hue'
require './color'

HUE_CLIENT = Hue::Client.new

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
    lights_to_act_on = HUE_CLIENT.lights
  elsif command.scan(/room/).length > 0
    lights_to_act_on = HUE_CLIENT.lights.select{|light| ZACH_ROOM_LIGHTS.include?(light.name.downcase)}
  else
    lights_to_act_on = HUE_CLIENT.lights.select{|light| command.split(" ").include?(light.name.downcase)}
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


  command = command.gsub("to hundred", "two hundred") if command.scan(/to hundred/).length > 0
  words = command.split(" ")


  index = words.index("brightness")
  if !index.nil?
    options[:color] = {} if !options[:color]
    brightness = (words[index..-1].join(" ")).in_numbers
    puts brightness
    for number in 1..10 do
      if brightness == number
        puts ((brightness.to_f/10.to_f)*255).to_i
        brightness = ((brightness.to_f/10.to_f)*255).to_i
      end
    end
    options[:color][:bri] = brightness
  end

  light_command(lights_to_act_on, options)
end
require 'hue'
require_relative './scenes/scenes'


class AlexaHue

  HUE_CLIENT = Hue::Client.new

  SATURATION_MODIFIERS = {lighter: 200, light: 200, darker: 255, dark: 255, darkest: 200}

  GROUPS = {}

  HUE_CLIENT.groups.each do |g| GROUPS[g.name] = g.id end 

  def wake_words
    ["light", "lights"]
  end

  def string_to_hue(string)
    mired_colors = {sleeping: 500, candle: 445, relaxing: 387, neutral: 327, reading: 286, working: 227, flourescent: 180}
    basic_color_hues = {red: 65280, pink: 56100, purple: 52180, violet: 47188, blue: 46920, turquoise: 31146, green: 25500, yellow: 12750, orange: 8618}
    if basic_color_hues.keys.include?(string.to_sym)
      directive = {hue: basic_color_hues[string.to_sym], saturation: 255}
    elsif mired_colors.keys.include?(string.to_sym)
      directive = {ct: mired_colors[string.to_sym]}
    end
  end

  def process_command(command)
    lights_to_act_on = []
    
    # Select lights
    if command.scan(/all/).length > 0
      lights_to_act_on = HUE_CLIENT.lights
    elsif  GROUPS.keys.any? { |g| command.include?(g.downcase) }
      GROUPS.keys.each do |k|
        if command.include?(k.downcase)
        lights_to_act_on = HUE_CLIENT.group(GROUPS[k])
        end
      end
    elsif SCENES.keys.any? { |n| command.include?(n.downcase.gsub('-',' ')) }
      SCENES.keys.each do |k|
        if command.include?(k.downcase.gsub('-', ' '))
          HUE_CLIENT.group(SCENES[k]).set_state({scene: k})
        end
      end
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
    if !index.nil?

      color_command = words[index + 1]
      options[:color] = string_to_hue(color_command)

    end

    command.gsub("leider", "lighter")
    command.gsub("later", "lighter")
    mapped_modifiers = SATURATION_MODIFIERS.keys.map{|k| "#{k.to_s}\\s" }
    scan_command = command.scan(/#{mapped_modifiers.join("|") if mapped_modifiers}/)
    if scan_command.length > 0
      scan_command = scan_command.map{|k| k.strip}
      options = {} if options.nil?
      options[:color] = {} if options[:color].nil?
      if scan_command[0] == "light" && !scan_command[1].nil? && scan_command[1] != "light"
        scan_command[0] = "dark"  
      end
      options[:color][:saturation] = SATURATION_MODIFIERS[scan_command[0].to_sym]
    end

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


  private

  def light_command(lights, options = {})
    p options
      if lights.class == Hue::Group
        lights.on = options[:on] if !options[:on].nil?
        lights.set_state(options[:color]) if !options[:color].nil?
        sleep(0.5)
      else lights.each do |light|
        light.on = options[:on] if !options[:on].nil?
        light.set_state(options[:color]) if !options[:color].nil?
        sleep(0.5)
      end
    end
  end
end

MODULE_INSTANCES.push(AlexaHue.new)

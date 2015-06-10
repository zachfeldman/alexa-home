require 'chronic'
require 'chronic_duration'
require 'httparty'
require 'numbers_in_words'
require 'numbers_in_words/duck_punch'

class Switch
	attr_accessor :command, :lights_array, :_group, :body, :schedule_params, :schedule_ids
	def initialize(command = "", _group = 0, &block)

		@user = "1234567890"
		@ip = HTTParty.get("https://www.meethue.com/api/nupnp").first["internalipaddress"]
		
		authorize_user
		populate_switch
		
		self.lights_array = []
		self.schedule_ids = []
		self.schedule_params = nil
		self.command = ""
		self._group = "0"
		self.body = {}
		instance_eval(&block) if block_given?
	end

	def authorize_user
		unless HTTParty.get("http://#{@ip}/api/#{@user}/config").include?("whitelist")
			if HTTParty.post("http://#{@ip}/api", :body => ({:devicetype => "Hue_Switch", :username=>"1234567890"}).to_json).first.include?("error")
				raise "You need to press the link button on the bridge and run again"
			end
		end
	end

	def populate_switch
		@colors = {red: 65280, pink: 56100, purple: 52180, violet: 47188, blue: 46920, turquoise: 31146, green: 25500, yellow: 12750, orange: 8618}
		@mired_colors = {candle: 500, relax: 467, reading: 346, neutral: 300, concentrate: 231, energize: 136}
		@scenes = [] ; HTTParty.get("http://#{@ip}/api/#{@user}/scenes").keys.each { |k| @scenes.push(k) }
		@groups = {} ; HTTParty.get("http://#{@ip}/api/#{@user}/groups").each { |k,v| @groups["#{v['name']}".downcase] = k } ; @groups["all"] = "0"
		@lights = {} ; HTTParty.get("http://#{@ip}/api/#{@user}/lights").each { |k,v| @lights["#{v['name']}".downcase] = k }
	end

	def hue (numeric_value)
		clear_attributes
		self.body[:hue] = numeric_value
	end

	def mired (numeric_value)
		clear_attributes
		self.body[:ct] = numeric_value
	end

	def color(color_name)
		clear_attributes
		@colors.keys.include?(color_name.to_sym) ?
		self.body[:hue] = @colors[color_name.to_sym] : self.body[:ct] = @mired_colors[color_name.to_sym]
	end

	def saturation(depth)
		self.body.delete(:scene)
		self.body[:sat] = depth
	end

	def brightness(depth)
		self.body.delete(:scene)
		self.body[:bri] = depth
	end

	def clear_attributes
		self.body.delete(:scene)
		self.body.delete(:ct)
		self.body.delete(:hue)
	end

	def fade(in_seconds)
		self.body[:transitiontime] = in_seconds * 10
	end	

	def light (*args)
		self.lights_array = []
		self._group = ""
		self.body.delete(:scene)
		args.each { |l| self.lights_array.push @lights[l.to_s] if @lights.keys.include?(l.to_s) }
	end

	def lights(group_name)
		self.lights_array = []
		self.body.delete(:scene)
		self._group = @groups[group_name.to_s]
	end

	def scene(scene_name)
		clear_attributes
		self.lights_array = []
		self._group = "0"
		self.body[:scene] = scene_name.to_s
	end

	def confirm
		params = {:alert => 'select'}
		HTTParty.put("http://#{@ip}/api/#{@user}/groups/0/action" , :body => params.to_json)
	end

	def save_scene(scene_name)
		scene_name.gsub!(' ','-')
		self.fade 2 if self.body[:transitiontime] == nil
		if self._group.empty?
			light_group = HTTParty.get("http://#{@ip}/api/#{@user}/groups/0")["lights"]
		else
			light_group = HTTParty.get("http://#{@ip}/api/#{@user}/groups/#{self._group}")["lights"]
		end
		params = {name: scene_name, lights: light_group, transitiontime: self.body[:transitiontime]}
		response = HTTParty.put("http://#{@ip}/api/#{@user}/scenes/#{scene_name}", :body => params.to_json)
		confirm if response.first.keys[0] == "success"
	end

	def lights_on_off
		self.lights_array.each { |l| HTTParty.put("http://#{@ip}/api/#{@user}/lights/#{l}/state", :body => (self.body).to_json) }
	end

	def group_on_off
		HTTParty.put("http://#{@ip}/api/#{@user}/groups/#{self._group}/action", :body => (self.body.reject { |s| s == :scene }).to_json)
	end

	def scene_on_off
		if self.body[:on] == true
			HTTParty.put("http://#{@ip}/api/#{@user}/groups/#{self._group}/action", :body => (self.body.select { |s| s == :scene }).to_json)
		elsif self.body[:on] == false
			# turn off individual lights in the scene
			(HTTParty.get("http://#{@ip}/api/#{@user}/scenes"))[self.body[:scene]]["lights"].each do |l|
				puts self.body
				HTTParty.put("http://#{@ip}/api/#{@user}/lights/#{l}/state", :body => (self.body).to_json)
			end
		end
	end

	def on
		self.body[:on]=true
		lights_on_off if self.lights_array.any?
		group_on_off if (!self._group.empty? && self.body[:scene].nil?)
		scene_on_off if !self.body[:scene].nil?
	end

	def off
		self.body[:on]=false
		lights_on_off if self.lights_array.any?
		group_on_off if (!self._group.empty? && self.body[:scene].nil?)
		scene_on_off if !self.body[:scene].nil?	
	end

	# Parses times in words (e.g., "eight forty five") to standard HH:MM format

	def numbers_to_times(numbers)
		numbers.map!(&:in_numbers)
		numbers.map!(&:to_s)
		numbers.push("0") if numbers[1] == nil
		numbers = numbers.shift + ':' + (numbers[0].to_i + numbers[1].to_i).to_s
		numbers.gsub!(':', ':0') if numbers.split(":")[1].length < 2
		numbers
	end

	def parse_time(string)
		string.sub!(" noon", " twelve in the afternoon")
		string.sub!("midnight", "twelve in the morning")
		time_modifier = string.downcase.scan(/(evening)|(night|tonight)|(afternoon)|(pm)|(a.m.)|(morning)|(today)/).flatten.compact.first
		guess = Time.now.strftime('%H').to_i >= 12 ?  "p.m." : "a.m."
		time_modifier = time_modifier.nil? ? guess : time_modifier
		day_modifier = string.scan(/(tomorrow)|(next )?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)/).flatten.compact.join(' ')
		numbers_in_words = string.scan(Regexp.union((1..59).map(&:in_words)))
		set_time = numbers_to_times(numbers_in_words)
		set_time = Chronic.parse(day_modifier +  ' ' + set_time + ' ' + time_modifier)
	end

	def set_time(string)
		if string.scan(/ seconds?| minutes?| hours?| days?| weeks?/).any? 
			set_time = Time.now + ChronicDuration.parse(string)
		elsif string.scan(/\d/).any?
			set_time = Chronic.parse(string)
		else
			set_time = parse_time(string)
		end
	end

	def schedule (on_or_off = :default, string)
		self.body[:on] = true if on_or_off == :on
		self.body[:on] = false if on_or_off == :off
		set_time = set_time(string)
		if set_time < Time.now 
			p "You've scheduled this in the past"
		else
			set_time = set_time.to_s.split(' ')[0..1].join(' ').sub(' ',"T")
			self.schedule_params = {:name=>"Hue_Switch Alarm",
						 :description=>"",
						 :localtime=>"#{set_time}",
						 :status=>"enabled",
						 :autodelete=>true
						}
			if self.lights_array.any?
				lights_array.each do |l|
					self.schedule_params[:command] = {:address=>"/api/#{@user}/lights/#{l}/state", :method=>"PUT", :body=>self.body}
				end
			else
				self.schedule_params[:command] = {:address=>"/api/#{@user}/groups/#{self._group}/action", :method=>"PUT", :body=>self.body}
			end
			self.schedule_ids.push(HTTParty.post("http://#{@ip}/api/#{@user}/schedules", :body => (self.schedule_params).to_json))
			confirm if self.schedule_ids.flatten.last.include?("success")
		end
	end

	def delete_schedules!
		self.schedule_ids.flatten!
		self.schedule_ids.each { |k| 
	 		id = k["success"]["id"] if k.include?("success")
	 		HTTParty.delete("http://#{@ip}/api/#{@user}/schedules/#{id}")
	 	}
	 	self.schedule_ids = []
	end

	def colorloop(start_or_stop)
		if start_or_stop == :start
			self.body[:effect] = "colorloop"
		elsif start_or_stop == :stop
			self.body[:effect] = "none"
		end
	end

	def alert(value)
		if value == :short
			self.body[:alert] = "select"
		elsif value == :long
			self.body[:alert] = "lselect"
		elsif value == :stop
			self.body[:alert] = "none"
		end
	end

	def reset
		self.command = ""
		self._group = "0"
		self.body = {}
		self.schedule_params = nil
	end

	#The following two methods are required to use Switch with Zach Feldman's Alexa-home*
	def wake_words
		["light", "lights", "scene", "seen"]
	end

	def process_command (command)
		command.sub!("color loop", "colorloop")
		command.sub!("too", "two")
		command.sub!("for", "four")
		command.sub!(/a half$/, 'thirty seconds')
		self.voice command
	end
	
	#The rest of the methods allow access to most of the Switch class functionality by supplying a single string.
	def parse_leading(methods)
		methods.each do |l|
			capture = (self.command.match (/\b#{l}\s\w+/)).to_s.split(' ')
			method = capture[0]
			value = capture[1]
			value = value.in_numbers if value.scan(Regexp.union( (1..10).map {|k| k.in_words} ) ).any?
			value = ((value.to_f/10.to_f)*255).to_i if (value.class == Fixnum) && (l != "fade")
			self.send( method, value )
		end
	end

	def parse_trailing(method)
		all_keys = Regexp.union((@groups.keys + @lights.keys).flatten)
		value = self.command.match(all_keys).to_s
		self.send( method.first, value )
	end

	def parse_dynamic(methods)
	methods.each do |d|
			capture = (self.command.match (/\w+ #{d}\b/)).to_s.split(' ')
			method = capture[1]
			value = capture[0].to_sym
			self.send( method, value )
		end
	end

	def parse_scene(scene_name)
		scene_name.gsub!(' ','-') if scene_name.size > 1
		scene_name.gsub!(/schedule-?/,'') if scene_name.include?('schedule')
		self.send("scene", scene_name)
	end
	
	def parse_save_scene
		save_scene = self.command.partition(/save (scene|seen) as /).last
		self.send( "save_scene", save_scene)
	end

	def parse_voice(string)
		trailing = string.split(' ') & %w[lights light]
		leading = string.split(' ') & %w[hue brightness saturation fade color]
		dynamic = string.split(' ') & %w[colorloop alert]
		scene_name = string.partition(" scene").first

		parse_scene(scene_name) if string.include?(" scene") && !string.include?("save")
		parse_leading(leading) if leading.any?
		parse_trailing(trailing) if trailing.any?
		parse_dynamic(dynamic) if dynamic.any?
		parse_save_scene if self.command.scan(/save (scene|seen) as/).length > 0
	end

	def voice(string)
		self.reset
		self.command << string
		string.gsub!('schedule','')

		parse_voice(string)

		if self.command.include?("schedule")
			self.body[:on] = true if string.include?(' on')
			self.body[:on] = false if string.include?(' off')
			self.send("schedule", string)
		else
			string.include?(' off') ? self.send("off") : self.send("on")
		end	
	end
end
MODULE_INSTANCES.push(Switch.new)
require 'httparty'
require 'chronic'
require 'hue'
require 'chronic_duration'
require 'numbers_in_words'
require 'numbers_in_words/duck_punch'

ALARM_TIMES = {} ; [*1..100].each { |t| ALARM_TIMES[t.in_words]=t }
IP = Hue::Client.new.bridge.ip
BRIDGE = "http://#{IP}/api/1234567890"
SCENES = [] ; (HTTParty.get("#{BRIDGE}/scenes").keys.each { |k| SCENES.push(k) if k =~ /^\D*$/ })

class AlexaAlarm

	def wake_words
		[/schedule.*?(scene|seen)/]
	end

	def process_command(command)
		command.gsub!("seen", "scene")
		@scene = command.match(/(?<=schedule\s).*(?=\sscene)/).to_s
		command.sub!(/schedule.*?scene (for|at|on)?/, '') ; command.strip!

		SCENES.each { |e| @scene = e if  e.downcase.sub('-',' ') == @scene }
		if !SCENES.include?(@scene)
			p "That scene doesn't exist"
		else
			@alarm = parse_time(command)
			
			params = {:name=>"Amazon Echo Alarm",
			 :description=>"",
			 :command=>{:address=>"/api/1234567890/groups/0/action", :method=>"PUT", :body=>{:scene=>"#{@scene}", :transitiontime=>100}},
			 :localtime=>"#{@alarm}",
			 :status=>"enabled",
			 :autodelete=>true
			}

			response = HTTParty.post("#{BRIDGE}/schedules", :body => params.to_json)
			
			if response.first.keys[0] == "success"
				p "#{@scene} scene scheduled for #{@confirm}"
				HTTParty.put("#{BRIDGE}/groups/0/action" , :body => ({:alert => 'select'}).to_json)
			else
				p "Alarm NOT Set!!!"
			end
		end
	end

	def parse_time(command)
		
		if command.scan(/ seconds?| minutes?| hours?| days?| weeks?/).any? 
		#set schedule relative to current time
			time = Time.now + ChronicDuration.parse(command)
			@confirm = time.strftime('%D %H:%M') 
			@alarm = time.to_s.split(' ')[0..1].join(' ').sub(' ',"T")
		
		else 
		#set schedule according to absolute time
			command.sub!(" noon", " twelve in the afternoon")
			command.sub!("midnight", "twelve in the morning")
			modifier = command.downcase.scan(/(in the evening|evening)|(at night|night|tonight)|(in the afternoon|this afternoon|afternoon)|(pm)|(a.m.)|(this morning|morning|in the morning)|(today)/).flatten.compact.first
			guess = Time.now.strftime('%H').to_i > 12 ?  "p.m." : "a.m."
			modifier = modifier.nil? ? guess : modifier
			command.sub!(modifier, '')

		# convert compound times in words (eight forty five) to HH:MM format that Chronic can understand	
			replace_time = command.scan(Regexp.union(ALARM_TIMES.keys))
			time = replace_time.map { |s| ALARM_TIMES[s].to_s }
			time = time.shift + ':' + (time[0].to_i + time[1].to_i).to_s
			time.gsub!(':', ':0') if time.split(":")[1].length < 2

		#set schedule
			time = Chronic.parse(time + " #{modifier}").strftime('%H:%M')
			command.gsub!(' oh ', ' ')
			command.gsub!(replace_time.join(' '), time) ; command.gsub!('  ',' ') ; command.strip!
			command.sub!(/at |for/,'')
			@confirm =  Chronic.parse(command).strftime('%D %H:%M') 
			@alarm = Chronic.parse(command).to_s.split(' ')[0..1].join(' ').sub(' ',"T")
		end
	end
end

MODULE_INSTANCES.push AlexaAlarm.new

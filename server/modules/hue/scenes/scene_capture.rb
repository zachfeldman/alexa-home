require 'hue'
require 'yaml'
require 'httparty'

LIGHTS_IN_GROUP = []
GROUPS = {}

@client ||= Hue::Client.new
@client.groups.each do |g| GROUPS[g.name] = g.id end 

def prompt(*args)
 print(*args)
 gets.chomp
end

def scene_in_group
	puts "\nHere are your groups:\n\n"
	puts GROUPS.keys
	group = prompt "\nEnter the group for this scene: "
		if GROUPS.keys.include?(group)
			@client.group((GROUPS[group]).to_i).lights.each { |l| LIGHTS_IN_GROUP.push(l.id) }
			@scene_group = GROUPS[group]
			puts "\nScene Created"
		else
			puts "\nThat group doesn't exist. Please choose from among your existing groups\n CTRL-C to exit\n"	
			scene_in_group
		end
end

scene_name = prompt "\nEnter the name of the scene: "
scene_name.gsub!(' ','-')
puts "\nThank you."

scene_in_group

params = {name: scene_name, lights:LIGHTS_IN_GROUP}

#adding scene to bridge
HTTParty.put("http://#{@client.bridge.ip}/api/#{@client.username}/scenes/#{scene_name}", :body => params.to_json)

scene_info = {scene_name => @scene_group}

File.open('scene_names.yml', 'a+') { |lines| lines.write(scene_info.to_yaml) }


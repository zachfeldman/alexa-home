require 'yaml'
	
scene_file = File.dirname(File.expand_path(__FILE__)) + '/scene_names.yml'
s = YAML.load_stream(open(scene_file))
SCENES = s.reduce :update


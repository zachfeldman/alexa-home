Scene Support

A small upgrade to support calling up Hue scenes with Alexa.

Background:
Scenes are stored/recalled on the bridge by scene ids. Since many Hue apps assign a random alphanumeric string for a scene id, it isn't practical to try to get Alexa to call up all existing scenes directly. A scene with the id "Dinner" can be called up; one with the id 0-AF45THX-11 cannot. Since currently the Hue API doesn't support renaming (or deletion) of scenes, it likely that most of your current scenes can't be accessed through an Alexa voice command.

Usage:
This add-on has two files 
- 'scene_names.yml' contains the names of the (voice-regognizable) scenes you want Alexa to recognize. 
- 'capture_scenes.rb' allows you to capture your current light configuration, and give it a name that Alexa *can* recognize.

Simply set your lights how you'd like, and run "ruby capture_scenes.rb" in the terminal. Name your scene and assign it to a group (names of existing groups will be listed). After you reset Alexa Home the scenes can be recalled, e.g., "Alexa, romantic lights"

(You can also add existing scene to the yaml file manually. You'll need to know the number of the group the scene is assigned to. That can be found with the Hue Debug Tool: http://<bridge ip address>/debug/clip.html)








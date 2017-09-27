# DEPRECATED
#
# SkillSystem is meant to be an Autoload Singleton.
# It enables all references to Skills to automatically
# use their name rather than their full path to acquire
# their script or scene.
extends Node

##### SIGNALS #####

##### CONSTANTS #####

##### EXPORTS #####

##### MEMBERS #####
var skills = {}

##### NOTIFICATIONS #####

func _ready():
	for name in skills:
		print(name, ": ", skills[name])

# Find all scene files with "skill" at the end of their name and map their names to their scene filepaths, example:
# "fire_wall"	: res://fire_wall_skill.tscn
# "fireWall"  	: res://dir/fireWallSkill.scn
func _init():
	var regex = RegEx.new()
	regex.compile("(?P<title>\\w*)(?:_s|S)kill\\.t?scn")
	var files = {}
	var dirs = ["res://"]
	var first = true
	while not dirs.empty():
		var dir = Directory.new()
		var dir_name = dirs.back()
		dirs.pop_back()
		if dir.open(dir_name) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir_name == "res://":
					first = false
				# If a directory, then add to list of directories to visit
				if dir.current_is_dir() and not file_name.begins_with("."):
					dirs.push_back(dir.get_current_dir() + "/" + file_name)
				# If a file, see if it's a Skill scene file. If so, map the skill name to the scene path
				else:
					var regexMatch = regex.search(file_name)
					if regexMatch != null:
						print("found file named: ", file_name)
						var skill_name = regexMatch.get_string("title")
						var path = dir.get_current_dir() + ("/" if not first else "") + file_name
						skills[ skill_name ] = path
						print("Adding ", skill_name, " mapping to ", path)
				# Move on to the next file in this directory
				file_name = dir.get_next()
			# We've exhausted all files in this directory. Close the iterator.
			dir.list_dir_end()

##### METHODS #####

func skill(p_name, p_preload = true):
	return load(skills[p_name])

##### SETTERS AND GETTERS #####
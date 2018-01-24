# A collection of shared static functions for the plugin's nodes

extends Reference

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####
const Skill = preload("skill.gd")
const SkillUser = preload("skill_user.gd")

##### EXPORTS #####

##### MEMBERS #####

##### NOTIFICATIONS #####

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

static func fetch_skill_user(p_node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor is SkillUser:
		ancestor = ancestor.get_parent()
	return ancestor

static func fetch_skill(p_node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor is Skill:
		ancestor = ancestor.get_parent()
	return ancestor

#static func search_res(p_regex):
#	var files = {}
#	var dirs = ["res://"]
#	var first = true
#	var data = {}
#	while not dirs.empty():
#		var dir = Directory.new()
#		var dir_name = dirs.back()
#		dirs.pop_back()
#		if dir.open(dir_name) == OK:
#			dir.list_dir_begin()
#			var file_name = dir.get_next()
#			while file_name != "":
#				if not dir_name == "res://":
#					first = false
#				# If a directory, then add to list of directories to visit
#				if dir.current_is_dir() and not file_name.begins_with("."):
#					dirs.push_back(dir.get_current_dir() + "/" + file_name)
#				# If a file, see if matches our regex. If so, map the skill name to the scene path
#				else:
#					var regexMatch = p_regex.search(file_name)
#					if regexMatch != null:
#						print("found file named: ", file_name)
#						var skill_name = regexMatch.get_string("title")
#						var path = dir.get_current_dir() + ("/" if not first else "") + file_name
#						data[ skill_name.capitalize() ] = path
#						print("Adding ", skill_name, " mapping to ", path)
#				# Move on to the next file in this directory
#				file_name = dir.get_next()
#			# We've exhausted all files in this directory. Close the iterator.
#			dir.list_dir_end()
#	return data

##### PRIVATE METHODS #####

##### SETTERS AND GETTERS #####
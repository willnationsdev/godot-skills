# SkillSystem is meant to be an Autoload Singleton.
# It enables all references to Skills to automatically
# use their name rather than their full path to acquire
# their script or scene.
extends Node

# If a targeter has already visited and updated its static group, then targeter_is_stale[(targeter_script_path)] == false
# If the SkillSystem has been notified that the group has become stale, then it will be 'true'
var targeter_is_stale = []
var regex = RegEx.new()

var skills = {}

func _ready():
    for name in skills:
        print(name, ": ", skills[name])

func get_targets(p_targeter_script, p_targeter_func):
    var group = p_targeter_script.get_path()

    # If we already have a collective target that is up-to-date, return the targeted collection
    if not targeter_is_stale[group]:
        return get_nodes_in_group(group)

    # Update the group to have all of the targets (and no other nodes)
    var nodes = get_nodes_in_group(group)
    nodes = p_targeter_func.call_func()
    targeter_is_stale[group] = false
    return nodes

    # for node in get_nodes_in_group(group):
    #     if not node in targets:
    #         node.remove_from_group(group)
    # for target in targets:
    #     if not target.is_in_group(group):
    #         target.add_to_group(group)

# Find all scene files with "skill" at the end of their name and map their names to their scene filepaths,
# e.g. fire_wall_skill.tscn and fireWallSkill.scn will be mapped to "fire_wall" and "fireWall" respectively.
func _init():
	#regex.compile("/(?P<filename>(?P<title>\\w*)(?:S|_s)kill\\.t?scn)\b/")
	#print(regex.compile("(?P<filename>(?P<title>\\w*)(?:S|_s)kill\\.t?scn)\\b"))
	regex.compile("(?P<title>\\w*)(?:_s|S)kill\\.t?scn")
	var files = {}
	var dirs = ["res://"]
	while not dirs.empty():
		var dir = Directory.new()
		var dir_name = dirs.back()
		dirs.pop_back()
		if dir.open(dir_name) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while true:
				if file_name == "":
					break;
				# If a directory, then add to list of directories to visit
				if dir.current_is_dir() and not file_name.begins_with("."):
					dirs.push_back(dir.get_current_dir() + "/" + file_name)
				# If a file, see if it's a Skill scene file. If so, map the skill name to the scene path
				else:
					var regexMatch = regex.search(file_name)
					if regexMatch != null:
						var skill_name = regexMatch.get_string("title")
						var path = dir.get_current_dir() + "/" + file_name
						skills[ skill_name ] = path
						print("Adding ", skill_name, " mapping to ", path)
				# Move on to the next file in this directory
				file_name = dir.get_next()
			# We've exhausted all files in this directory. Close the iterator.
			dir.list_dir_end()

func skill(p_name):
	return load(skills[p_name])
# A collection of shared static functions for the plugin's nodes

extends Reference
class_name GDSUtility

##### CLASSES #####

##### SIGNALS #####

##### CONSTANTS #####

const CONNECTION_PREFIX = "_on_"
const TSName = "gds_targeting_server"

##### EXPORTS #####

##### MEMBERS #####

##### NOTIFICATIONS #####

##### OVERRIDES #####

##### VIRTUALS #####

##### PUBLIC METHODS #####

static func fetch_skill_user(p_node: Node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor.has_method("get_skills"):
		ancestor = ancestor.get_parent()
	return ancestor

static func fetch_skill(p_node: Node):
	var ancestor = p_node.get_parent()
	while ancestor and not ancestor.has_method("apply"):
		ancestor = ancestor.get_parent()
	return ancestor

static func setup(p_node: Node, p_is_entering: bool):
	# hook into parent cache
	var parent := p_node.get_parent()
	var type := p_node.get_script().resource_path.get_basename().get_file()
	var getter := "get_" + type + "s"
	assert parent and parent.has_method(getter) and typeof(parent.call(getter)) == TYPE_ARRAY
	parent.call(getter).call("append" if p_is_entering else "erase", p_node)

	# setup signals
	var target: Node = null
	if parent and parent.has_method("get_signal_target"):
		target = parent.get_signal_target() as Node
	if target:
		for a_signal in p_node.SIGNALS:
			var method = CONNECTION_PREFIX + a_signal
			if target.has_method(method):
				p_node.call("connect" if p_is_entering else "disconnect", a_signal, owner, method)

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
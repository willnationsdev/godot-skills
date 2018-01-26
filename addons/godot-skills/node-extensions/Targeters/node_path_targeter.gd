# Targets the node at the given NodePath, if it exists.
extends "res://addons/godot-skills/api/targeter.gd"

export(NodePath) var node_path = null

# @return Array The node at the defined path or empty array if null
func _get_targets(p_params):
	var r_targets = []
	if has_node(node_path):
		r_targets.append(get_node(node_path))
    return r_targets

func _init():
	node_path = null

func _match_skill_user(p_skill_user):
	#print("in targeter: ", get_path(), " > nodepath: ", node_path)
	if node_path or not has_node(node_path:
		return false
	var node = get_node(node_path)
	var result = node == p_skill_user
	#print("result: ", result)
	return result